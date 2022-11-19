import logging
import argparse
import os
import sys
from panoptes_client import Workflow, Caesar, Panoptes


def workflow_exists_in_caesar():
    if caesar.get_workflow(zoo_api_workflow.id) == None:
        logger.error('Caesar does not know about this workflow!')
        return False
    else:
        logger.info('Workflow exists in Caesar!')
        return True

def create_workflow_extractors():
    extractors = caesar.get_workflow_extractors(zoo_api_workflow.id)
    if extractors:
      existing_extractors = [extractor['key'] for extractor in extractors]
      task_keys_to_setup = list(set(GZ_DECISION_TREE_TASK_KEYS.keys()) - set(existing_extractors))
      # a more sophisticated check would involve looking into the config
      # to make sure it's correct but we don't need this now
      # e.g.
      # extractor['config']['task_key'] == 'T0'
      # extractor['config']['if_missing'] == 'reject'
    else:
      task_keys_to_setup = GZ_DECISION_TREE_TASK_KEYS.keys()

    task_extractor_type = 'question'
    extractor_config_attrs = {'if_missing': 'reject'}

    for extractor_key in task_keys_to_setup:
      logger.info('Adding extractor for task key: %s' % extractor_key)
      # https://panoptes-python-client.readthedocs.io/en/latest/_modules/panoptes_client/caesar.html#Caesar.create_workflow_extractor
      caesar.create_workflow_extractor(zoo_api_workflow.id, extractor_key, task_extractor_type, task_key=extractor_key, other_extractor_attributes=extractor_config_attrs)

    logger.info('Workflow extractors setup')

def create_workflow_reducers():
    reducers = caesar.get_workflow_reducers(zoo_api_workflow.id)
    if reducers:
      count_reducer_tasks_to_setup = []
      sum_reducer_tasks_to_setup = []
      # these checks could be more sophisticated but will work of key name presence for now
      # count reducers
      existing_count_reducers = [reducer['key'] for reducer in reducers if reducer['key'].endswith('_count')]
      count_reducer_tasks_to_setup = list(set(COUNT_REDUCER_KEYS.keys()) - set(existing_count_reducers))
      # sum reducers
      existing_sum_reducers = [reducer['key'] for reducer in reducers if reducer['key'].endswith('_sum')]
      sum_reducer_tasks_to_setup = list(set(SUM_REDUCER_KEYS.keys()) - set(existing_sum_reducers))
    else:
      # set all the sum and count reducers up :)
      count_reducer_tasks_to_setup = COUNT_REDUCER_KEYS.keys()
      sum_reducer_tasks_to_setup = SUM_REDUCER_KEYS.keys()

    for task in count_reducer_tasks_to_setup:
        # https://panoptes-python-client.readthedocs.io/en/latest/_modules/panoptes_client/caesar.html
        # setup the 'count' reducer with key {$task_key}_count
        logger.info(f'Adding reducer for task key: {task}')
        reducer_filter_attrs = {'empty_extracts': 'ignore_empty','extractor_keys': [COUNT_REDUCER_KEYS[task]], 'repeated_classifications': 'keep_first'}
        caesar.create_workflow_reducer(zoo_api_workflow.id, 'count', task, other_reducer_attributes={'filters': reducer_filter_attrs})
    for task in sum_reducer_tasks_to_setup:
        # setup the 'stats' reducer with key {$task_key}_sum
        logger.info(f'Adding reducer for task key: {task}')
        reducer_filter_attrs = {'empty_extracts': 'ignore_empty','extractor_keys': [SUM_REDUCER_KEYS[task]], 'repeated_classifications': 'keep_first'}
        caesar.create_workflow_reducer(zoo_api_workflow.id, 'stats', task, other_reducer_attributes={'filters': reducer_filter_attrs})

    logger.info('Workflow reducers setup')

if __name__ == '__main__':
    """
    Setup a an Active Learning Loop workflow for Caesar
    For the Cosmic Dawn Survey dataset
    """
    FORMAT = '%(asctime)s - %(levelname)s - %(message)s'
    # set level to DEBUG to get the panoptes network traffic
    logging.basicConfig(level=logging.INFO, format=FORMAT, force=True)
    logger = logging.getLogger('setup_caesar')

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

    # currently all extractors are 'question' type, if this changes we can add them here for task key lookup tuple
    GZ_DECISION_TREE_TASK_KEYS = {'T0':True,'T1':True,'T2':True,'T3':True,'T4':True,'T5':True,'T6':True,'T7':True,'T8':True,'T11':True,'T12':True,'T13':True,'T14':True,'T15':True}
    # setup known count reducer keys
    COUNT_REDUCER_KEYS = {f'{task_key}_count': task_key for task_key in GZ_DECISION_TREE_TASK_KEYS}
    # setup known sum reducer keys
    SUM_REDUCER_KEYS = {f'{task_key}_sum': task_key for task_key in GZ_DECISION_TREE_TASK_KEYS}

    # lookup the worklfow
    zoo_api_workflow = Workflow.find(args.workflow_id)
    if not zoo_api_workflow:
      logger.error('No workflow found in the Zooniverse API')
      exit(1)

    logger.info('Checking the workflow exists in Caesar!')
    if workflow_exists_in_caesar():
        logger.info('Proceeding to create the extractors')
        create_workflow_extractors()
        logger.info('Proceeding to create the reducers')
        create_workflow_reducers()

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

