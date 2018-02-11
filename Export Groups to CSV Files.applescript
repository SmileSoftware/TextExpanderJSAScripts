// Export Groups to TextExpander Files.
//
// Export user-selected groups to user-selected destination folder in CSV format.
//
// Copyright 2018 SmileOnMyMac, LLC. See LICENSE.md for license terms.

// Preliminaries
TextExpander = Application('TextExpander');
Finder = Application('Finder');
currentApp = Application.currentApplication();
currentApp.includeStandardAdditions = true;

// Get sorted list of group names
groupNames = TextExpander.groups.name().sort();

// Let user pick group(s) to process
listResult = currentApp.chooseFromList(groupNames, {withTitle:'Groups', withPrompt:'Please pick group(s) to search.', multipleSelectionsAllowed:true, emptySelectionAllowed:false});

// Let user pick destination folder
folderResult = currentApp.chooseFolder({withPrompt:'Please choose the folder into which to write the exported groups, or make one using the New Folder button.'})

listResult.forEach(function(groupName) {
	groupNameForSaving = groupName;
	groupNameForSaving = groupNameForSaving.replace(/\./g, "_");
	filePath = Path(folderResult + '/' + groupNameForSaving + '.csv');
	var groupExport = '';
	const aGroup = TextExpander.groups.whose({name:{_equals:groupName}})[0];
	aGroup.snippets().forEach(function(aSnippet) {
		if (groupExport.length > 0) {
			groupExport += '\r';
		}
		abbreviation = aSnippet.abbreviation();
		abbreviation = abbreviation.replace(/"/g,'""');
		plainText = aSnippet.plainTextExpansion();
		plainText = plainText.replace(/"/g,'""');
		if (abbreviation.length > 0 || plainText.length > 0) {
			label = aSnippet.label();
			groupExport += `"${abbreviation}","${plainText}","${label}"`;
		}

	});
	str = $.NSString.alloc.initWithUTF8String(groupExport);
	str.writeToFileAtomicallyEncodingError(filePath.toString(), true, $.NSUTF8StringEncoding, null);
});

Finder.open(folderResult);
currentApp.displayDialog('Export completed.', {buttons:['OK'], defaultButton:'OK'});
