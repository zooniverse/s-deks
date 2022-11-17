import logging
import argparse
import os
from panoptes_client import Workflow, Caesar, Panoptes


def workflow_exists_in_caesar():
    if caesar.get_workflow(zoo_api_workflow.id) == None:
        logger.error('Caesar does not know about this workflow!')
        return False
    else:
        logger.info('Workflow exists in Caesar!')
        return True


def create_workflow_extractors():
  # currently all extractors are 'question' type, if this changes we can add them here for task key lookup tuple
    known_keys = {'T0':True,'T1':True,'T2':True,'T3':True,'T4':True,'T5':True,'T6':True,'T7':True,'T8':True,'T11':True,'T12':True,'T13':True,'T14':True,'T15':True}

    extractors = caesar.get_workflow_extractors(zoo_api_workflow.id)
    if extractors:
      task_keys_to_setup = []
      for extractor in extractors:
          if not known_keys.get(extractor['key'], None):
              # collect all unknown extractor keys so we can set them up
              task_keys_to_setup.append(extractor['key'])
              # are more sophisticated check would involve looking into the config
              # to make sure it's correct but we don't need this now
              # e.g.
              # extractor['config']['task_key'] == 'T0'
              # extractor['config']['if_missing'] == 'reject'
    else:
      task_keys_to_setup = known_keys.keys()

    task_extractor_type = 'question'
    extractor_config_attrs = {'if_missing': 'reject'}

    import pdb
    pdb.set_trace()

    for extractor_key in task_keys_to_setup:
      caesar.validate_extractor_type(task_extractor_type)
      logger.info('Adding extractor for task key: %s' % extractor_key)
      caesar.create_workflow_extractor(zoo_api_workflow.id, extractor_key, task_extractor_type, task_key=extractor_key, other_extractor_attributes=extractor_config_attrs)

    logger.info('Workflow extractors setup')


# def create_workflow_extractors():
#   if workflow_extractors_exist():
#       logger.info('All Extrators already exist for this workflow!')
#       return
#   else:
#       logger.info('Extractors')


    # question_extractor_attributes = {
    #     'if_missing': question_extractor_if_missing,
    #     **other_question_extractor_attrib
    # }

    # alice_extractor_attributes = {
    #     'url': f'https://aggregation-caesar.zooniverse.org/extractors/line_text_extractor?task={alice_task_key}',
    #     **other_alice_extractor_attrib
    # }

if __name__ == '__main__':
    """
    Setup a an Active Learning Loop workflow for Caesar
    For the Cosmic Dawn Survey dataset
    """

    logger = logging.getLogger('panoptes_client')
    logger.setLevel(logging.INFO)
    # formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    # handler = logging.StreamHandler(sys.stdout)
    # handler.setFormatter(formatter)
    # logger.addHandler(handler)

    parser = argparse.ArgumentParser()
    parser.add_argument('--env', dest='caesar_env', type=str, choices=['production', 'staging'], default='production')
    parser.add_argument('--workflow-id', dest='workflow_id', type=str, required=True)
    parser.add_argument('--env-credentials', dest='non_interactive_login', action='store_true')

    args = parser.parse_args()

    if args.caesar_env == 'production':
        caesar_endpoint = 'https://caesar.zooniverse.org'
        panoptes_endpoint = 'https://www.zooniverse.org'
    else:
        caesar_endpoint = 'https://caesar-staging.zooniverse.org'
        panoptes_endpoint = 'https://panoptes-staging.zooniverse.org'

    # Login to gain access to Zooniverse APIs
    if args.non_interactive_login:
      Panoptes.connect(username=os.environ.get('USERNAME', ''), password=os.environ.get('PASSWORD', ''), endpoint=panoptes_endpoint)
    else:
      Panoptes.connect(login='interactive', endpoint=panoptes_endpoint)

    logger.info('Logged into Zooniverse')

    caesar = Caesar(endpoint=caesar_endpoint)

    # lookup the worklfow
    zoo_api_workflow = Workflow.find(args.workflow_id)
    if not zoo_api_workflow:
      logger.error('No workflow found in the Zooniverse API')
      exit(1)

    logger.info('Checking the workflow exists in Caesar!')
    if workflow_exists_in_caesar():
        logger.info('Proceeding to create the extractors')
        create_workflow_extractors()

    else:
       # longer term this could be automated but I think it's better to not create workflows in caesar
       # and ensure a human intervenes to set this up and allow the rest of the resources to be created
       # i.e. make sure this behaviour what is wanted!
       raise Exception('Workflow does not exist in Caesar! please visit caesar and set it up first!')





    # TODO: ensure we can override the endpoint to hit staging / production via function arg

    # ensure the workflow exists
    # create the extractors
    # then the reducers
    # then the subject rules
    # then the subject rule effects (these post data to KaDE)

