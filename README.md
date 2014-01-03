splunk-svm
==========

Splunk startup and shutdown script for demo environments

Splunk environment helper for Macs
Version 1.3

Fixes in 1.1
fixed svm started, used to break if - or . was in the Splunk instance name

Features new in 1.2
 svm stop-all
 stop all running Splunk instances
 svm stop-others
 stop all running Splunk instances except the current select Splunk instance



Features new in 1.3
 svm restart-all
 restarts all splunk instances 
 svm rebase
 resets SPLUNK_BASE to the current directory
 svm cmd-all <cmd>
 runs cmd in all splunk instances 
 svm cmd-started <cmd>
 runs cmd in running splunk instances 
 tab completion semi-fixes (still some TODO)

Feature requests not implemented
 svm install
 this should install a new Splunk instance from config zip file location and assign new web/managment ports, the name of the splunk instance will be a command line arg

Setup instructions are in the top of the bashrc file


