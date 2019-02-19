from elastalert.alerts import Alerter, CommandAlerter, BasicMatchString
from elastalert.util import elastalert_logger


#
#   The NagiosAlerter uses the command send_nrdp.py to send passive check results to a Nagios Server
#
#   Requirements:
#
#       1) On ElastAlert side send_nrdp.py must be installed
#           Example for ElastAlert Docker container:
#               RUN cd /tmp/ && \
#                   wget https://github.com/NagiosEnterprises/nrdp/archive/1.5.2.tar.gz && \
#                   tar xvf 1.5.2.tar.gz && \
#                   cd nrdp-* && \
#                   mkdir /usr/local/nrdp && \
#                   cp -r clients /usr/local/nrdp && \
#                   rm -rf /tmp/nrdp-*
#
#       2) On Nagios side NRDP agent must be installed
#           Example for Nagios Docker container:
#               RUN cd /tmp/ && \
#                   wget https://github.com/NagiosEnterprises/nrdp/archive/1.5.2.tar.gz && \
#                   tar xvf 1.5.2.tar.gz && \
#                   cd nrdp-* && \
#                   mkdir /usr/local/nrdp && \
#                   cp -r clients server LICENSE* CHANGES* /usr/local/nrdp && \
#                   chown -R nagios:nagios /usr/local/nrdp && \
#                   cp /tmp/nrdp-1.5.2/nrdp.conf /etc/apache2/sites-available/ && \
#                   ln -s /etc/apache2/sites-available/nrdp.conf /etc/apache2/sites-enabled/nrdp.conf && \
#                   rm -rf /tmp/nrdp-* && \
#                   apt-get update && \
#                   apt-get -y install php-xml
#
#
#   The following options are required:
#       - nagios_nrdp_command   location and filename of the NRDP command (e.g. /usr/local/nrdp/clients/send_nrdp.py)
#       - nagios_server         hostname of the Nagios server (e.g. nagios)
#       - nagios_token          Token as defined in NRDP config of Nagios (must be allowed to send passive check results on Nagios side!)
#       - nagios_host           Host_name of the service check in Nagios
#       - nagios_service        Service_name of the service check in Nagios
#       - nagios_status         Status to be sent to Nagios for the mentioned service (e.g. 0=OK, 1=WARNING, 2=CRITICAL, 3=UNKNOWN)
#
#   The following options are optional:
#       - nagios_username       username of the account to access Nagios frontend
#       - nagios_password       password of the account to access Nagios frontend
#       - alert_subject         this field is used for the output of the check result
#
class NagiosAlerter(CommandAlerter):

    # By setting required_options to a set of strings
    # You can ensure that the rule config file specifies all
    # of the options. Otherwise, ElastAlert will throw an exception
    # when trying to load the rule.
    required_options = frozenset(['nagios_nrdp_command', 'nagios_server', 'nagios_token', 'nagios_host', 'nagios_service', 'nagios_status'])

    # Constructor of the class
    def __init__(self, rule):

        elastalert_logger.debug("NagiosAlerter::__init__ - start")

        # fill required option command for superclass CommandAlerter with dummy (to supress exceptions)
        # the option will be filled with real command in alert method of this class
        rule['command'] = 'dummy'
        # call superclass constructor
        super(NagiosAlerter, self).__init__(rule)

        # fill own class properties
        elastalert_logger.debug("NagiosAlerter::__init__ - filling class properties")
        self.nagios_nrdp_command = self.rule['nagios_nrdp_command']

        self.nagios_token = self.rule['nagios_token']
        self.nagios_host = self.rule['nagios_host']
        self.nagios_service = self.rule['nagios_service']
        # status: 0=OK, 1=WARNING, 2=ERROR, 3=UNKNOWN
        self.nagios_status = self.rule['nagios_status']

        # Build nagios URL (http://nagios_user:nagios_password@nagios_server/nrdp or http://nagios_server/nrdp)
        self.nagios_url = 'http://'
        if len(self.rule['nagios_user']):
            self.nagios_url += self.rule['nagios_user']
        if len(self.rule['nagios_password']):
            self.nagios_url += ':' + self.rule['nagios_password']
        if len(self.rule['nagios_user']):
            self.nagios_url += '@'
        self.nagios_url += self.rule['nagios_server'] + '/nrdp'

        elastalert_logger.info("NagiosAlerter initialized")


    # Alert method is called when a rule matches and an alert should be sent
    def alert(self, matches):

        elastalert_logger.debug("NagiosAlerter::alert - start")

        nagios_args = ' -t ' + self.nagios_token + ' -H "' + self.nagios_host + '" -s "' + self.nagios_service + '" -S ' + str(self.nagios_status) + ' -o "' + self.rule['alert_subject'] + '"'

        self.rule['command'] = [ self.nagios_nrdp_command + " -u " + self.nagios_url + nagios_args ]

        elastalert_logger.debug("NagiosAlerter::alert - calling alert method of superclass")
        super(NagiosAlerter, self).alert(matches)

        elastalert_logger.info("NagiosAlerter::alert - finished")

    # get_info is called after an alert is sent to get data that is written back
    # to Elasticsearch in the field "alert_info"
    # It should return a dict of information relevant to what the alert does
    def get_info(self):
        return {'type':     'Nagios NRDP Alerter',
                'nagios_host':     self.nagios_host,
                'nagios_service':  self.nagios_service,
                'nagios_status':   self.nagios_status,
                'nagios_output':   self.rule['alert_subject']
                }

