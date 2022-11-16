import logging
import argparse
import os
from panoptes_client import Workflow, Caesar, Panoptes


def workflow_exists_in_caesar(workflow_id):
    if caesar.get_workflow(workflow_id) == None:
        logger.error('Caesar does not know about this workflow!')
        return False
    else:
        logger.info('Workflow exists in Caesar!')
        return True


def create_workflow_extractors():
    question_extractor_attributes = {
        'if_missing': question_extractor_if_missing,
        **other_question_extractor_attrib
    }

    alice_extractor_attributes = {
        'url': f'https://aggregation-caesar.zooniverse.org/extractors/line_text_extractor?task={alice_task_key}',
        **other_alice_extractor_attrib
    }

if __name__ == '__main__':
    """
    Setup a an Active Learning Loop workflow for Caesar
    For the Cosmic Dawn Survey dataset
    """

    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    # formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    # handler = logging.StreamHandler(sys.stdout)
    # handler.setFormatter(formatter)
    # logger.addHandler(handler)

    parser = argparse.ArgumentParser()
    parser.add_argument('--env', dest='caesar_env', type=str, choices=['production', 'staging'], default='production')
    parser.add_argument('--workflow-id', dest='workflow_id', type=str, required=True)
    parser.add_argument('--env-credentials', dest='non_interactive_login', type=bool, default=False)

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

    logger.info('Checking the workflow exists in Caesar!')
    if workflow_exists_in_caesar(args.workflow_id):
        logger.info('Proceeding to create the extractors')
        # create_workflow_extractors(args.workflow_id)

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

