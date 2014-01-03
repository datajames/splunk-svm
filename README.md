splunk-svm
==========

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


=======
Splunk Version Manager

svm is a command that allows you to switch between different splunks in your
terminal.

Additionally, the included bashrc will enhance your prompt to show the
currently selected splunk and the splunkd ports of all running splunk instances
under SPLUNK\_BASE.

Installing
----------

svm supplies a set of bash functions. Edit the included bashrc to specify the
location where your Splunks are located (SPLUNK\_BASE), and to specify a default
Splunk (SPLUNK\_DEFAULT).

svm assumes that your splunks are installed in different folders under the
SPLUNK\_BASE folder.

Include the bashrc in your ~/.bashrc
```bash
source /path/to/svm/bashrc
```
On Mac OSX you may not have a default bashrc, in which case, create the bashrc
as above, then place the following in your ~/.bash_profile
```bash
[[ -s ~/.bashrc ]] && source ~/.bashrc
```

Using
-----

Switching to the my-test-splunk install:
    svm my-test-splunk

### Informational functions

1. svm list - shows all splunk instances and their versions and ports
2. svm started - shows all currently running splunk instances
3. svm latest - show the latest version of splunk available from splunk.com

### Convenience functions

1. svm open - open the default web browser to the currently selected splunk
   instance
2. svm rebase - change SPLUNK\_BASE to be the current directory
3. svm home - changes directory to the SPLUNK\_HOME of the currently selected
   instance.

### Controlling running splunks

1. svm cmd-all <command> - runs the specified command in the context of each
   splunk
2. svm cmd-started <command> - runs the specified command in the context of
   each running splunk
3. svm stop-all - stops all splunks
4. svm stop-others - stops all splunks other than the currently selected
   instance

