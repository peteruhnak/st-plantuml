"
I am a simple editor for PlantUML
"
Class {
	#name : #PlantUMLEditor,
	#superclass : #ComposableModel,
	#instVars : [
		'client',
		'textPresenter',
		'imagePresenter',
		'toolbarPresenter',
		'editedFile'
	],
	#category : #PlantUML
}

{ #category : #specs }
PlantUMLEditor class >> defaultSpec [
	^ SpecColumnLayout composed
		add: #toolbarPresenter height: self toolbarHeight;
		newRow: [ :r | 
			r
				add: #textPresenter;
				add: #imagePresenter ];
		yourself
]

{ #category : #'world menu' }
PlantUMLEditor class >> menuCommandOn: aBuilder [
	<worldMenu>
	(aBuilder item: #PlantUML)
		parent: #MostUsedTools;
		withSeparatorAfter;
		action: [ self open ]
]

{ #category : #specs }
PlantUMLEditor class >> open [
	<script>
	self new openWithSpec
]

{ #category : #accessing }
PlantUMLEditor >> client [
	^ client ifNil: [ client := self newClient ]
]

{ #category : #actions }
PlantUMLEditor >> exportImage [
]

{ #category : #'accessing - spec fields' }
PlantUMLEditor >> imagePresenter [
	^ imagePresenter
]

{ #category : #api }
PlantUMLEditor >> initialExtent [
	^ 800 @ 600
]

{ #category : #initialization }
PlantUMLEditor >> initializeMenu [
	toolbarPresenter
		addGroup: [ :group | 
			group
				addItem: [ :item | 
					item
						name: nil;
						description: 'Open';
						icon: (self iconNamed: #openIcon);
						action: [ self openFile ] ].
			group
				addItem: [ :item | 
					item
						name: nil;
						description: 'Save';
						icon: (self iconNamed: #smallSaveIcon);
						action: [ self saveFile ] ].
			group
				addItem: [ :item | 
					item
						name: nil;
						description: 'Save As';
						icon: (self iconNamed: #smallSaveAsIcon);
						action: [ self saveFileAs ] ] ];
		addGroup: [ :group | 
			group
				addItem: [ :item | 
					item
						name: nil;
						description: 'Export as...';
						icon: (self iconNamed: #image);
						action: [ self exportImage ] ] ].
	toolbarPresenter applyTo: self
]

{ #category : #initialization }
PlantUMLEditor >> initializePresenter [
	super initializePresenter.
	textPresenter
		whenTextChanged:
			[ :text | self client generate: text asString do: [ :form | imagePresenter form: form ] ]
]

{ #category : #initialization }
PlantUMLEditor >> initializeWidgets [
	textPresenter := self newText autoAccept: true.
	imagePresenter := self instantiate: ScrollableImageModel.
	toolbarPresenter := self instantiate: MenuModel.
	self initializeMenu.
	self focusOrder add: textPresenter
]

{ #category : #accessing }
PlantUMLEditor >> newClient [
	^ PlantUMLClient new
		prepareClient;
		yourself
]

{ #category : #actions }
PlantUMLEditor >> openFile [
	FDOpenFileDialog new
		whenSelected: [ :file | self openFile: file ];
		extensionFilters:
			{'PlantUML files' -> #(puml plantuml).
			'All files' -> #()};
		defaultFolder: (editedFile ifNil: [ FileLocator imageDirectory asFileReference ] ifNotNil: #parent);
		open
]

{ #category : #actions }
PlantUMLEditor >> openFile: aFileReference [
	editedFile := aFileReference.
	textPresenter text: editedFile contents
]

{ #category : #actions }
PlantUMLEditor >> saveFile [
	editedFile ifNil: [ ^ self saveFileAs ].
	self saveFileAs: editedFile
]

{ #category : #actions }
PlantUMLEditor >> saveFileAs [
	FDSaveFileDialog new
		whenSelected: [ :file | self saveFileAs: file ];
		extensionFilters:
			{'PlantUML files' -> #(puml plantuml).
			'All files' -> #()};
		defaultFolder: (editedFile ifNil: [ FileLocator imageDirectory asFileReference ] ifNotNil: #parent);
		open
]

{ #category : #actions }
PlantUMLEditor >> saveFileAs: aFileReference [
	editedFile := aFileReference.
	editedFile
		ensureDelete;
		writeStreamDo: [ :stream | stream << textPresenter text asString ]
]

{ #category : #'accessing - spec fields' }
PlantUMLEditor >> textPresenter [
	^ textPresenter
]

{ #category : #'accessing - spec fields' }
PlantUMLEditor >> toolbarPresenter [
	^ toolbarPresenter
]
