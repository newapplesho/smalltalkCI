"Get the Metacello configuration (for Squeak users)"
Installer gemsource
    project: 'metacello';
    addPackage: 'ConfigurationOfMetacello';
    install.

"Bootstrap Metacello Preview, using mcz files (#'previewBootstrap' symbolic version"
((Smalltalk at: #ConfigurationOfMetacello) project 
  version: #'previewBootstrap') load.

"Load the Preview version of Metacello from GitHub"
(Smalltalk at: #Metacello) new
  configuration: 'MetacelloPreview';
  version: #stable;
  repository: 'github://dalehenrich/metacello-work:configuration';
  load.

"Now load latest version of Metacello"
(Smalltalk at: #Metacello) new
  baseline: 'Metacello';
  repository: 'github://dalehenrich/metacello-work:master/repository';
  get.
(Smalltalk at: #Metacello) new
  baseline: 'Metacello';
  repository: 'github://dalehenrich/metacello-work:master/repository';
  load.
!
| exportName scriptsDirectory fileDirectoryClass fileInBlock resultFileBlock |
exportName := 'TravisCI.image'.
scriptsDirectory := 'scripts/'.
fileDirectoryClass := Smalltalk at: #'FileDirectory'.
fileInBlock := [ :fileName | 
    fileDirectoryClass default
      readOnlyFileNamed: scriptsDirectory, fileName
      do: [ :fileStream | fileStream fileIn ] ].

fileInBlock value: 'MetacelloBuilderTravisCI.st'.
fileInBlock value: 'CommandLineToolSet.st'.
fileInBlock value: 'travisCIHarness.st'.

resultFileBlock := [ :resultsFileName :streamBlock |
      fileDirectoryClass default forceNewFileNamed: resultsFileName do: streamBlock ].
Smalltalk at: #'TravisResultFileBlock' put: resultFileBlock.

Smalltalk at: #'OLDTranscript' put: Transcript.

"If e.g. your tests change code in the image dynamically, the image will require you to set 
author initials which might fail these tests. So we set some dummy initials here to avoid this."
(Smalltalk at: #MetacelloPlatform) current authorName: 'travisCI'.

"Export and quit image"
Smalltalk at: #WorldState ifPresent: [:global |
  global addDeferredUIMessage: [
    Smalltalk at: #SmalltalkImage ifPresent: [:image |
      image current saveAs: exportName.
      "Snapshot image again but close this time"
      image current snapshot: true andQuit: true ]]].
!