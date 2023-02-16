# frozen_string_literal: true

class PredictionManifestExportJob
  include Sidekiq::Job

  def perform(active_subject_set_id = nil)
    # default to the GZ context active subject set id, but allow it to be overidden via job params
    active_subject_set_id ||= Context.find(ENV.fetch('ZOOBOT_GZ_CONTEXT_ID')).active_subject_set_id

    # NOTE: if we have a failure anywere after this point sadly we pay the cost to recreate the manifest
    # ideally we'd add a PredictionExport resource model to track the creation
    # and some smarts here to re-use an existing, recent manifest (perhaps 12 hours?)
    # to avoid reprocessing the same data if we have a job failure (creation / submissione etc)
    export_manifest_service = Batch::Prediction::ExportManifest.new(active_subject_set_id)
    export_manifest_service.run

    # create a prediction job resource
    prediction_job = PredictionJob.create!(prediction_job_params(active_subject_set_id, export_manifest_service.manifest_url))

    # submit the prediction job for processing
    PredictionJobSubmissionJob.perform_async(prediction_job.id)
  end

  private

  # NOTE: These are the same as in the predictions_controller
  # perhaps these can be extracted to a common service object that allows
  # for args that overrdie the env default values
  # DRY vs KISS and don't abstract too early
  def prediction_job_params(subject_set_id, manifest_url)
    {
      state: :pending,
      manifest_url: manifest_url,
      subject_set_id: subject_set_id,
      # NOTE: the below defaults could also move to the context model as required
      # threshold on subjects 80% predicted not likely to be smooth
      probability_threshold: ENV.fetch('PREDICTION_JOB_PROBABILITY_THRESHOLD_DEFAULT', '0.8').to_f,
      # attempt to add 10% of the 'smooth' prediction subjects for some randomisation of the data (avoid overfitting the model etc)
      randomisation_factor: ENV.fetch('PREDICTION_JOB_RANDOMISATION_FACTOR_DEFAULT', '0.1').to_f
    }
  end
end
