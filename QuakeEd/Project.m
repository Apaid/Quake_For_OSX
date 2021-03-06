//======================================
//
// QuakeEd Project Management
//
//======================================

#import "qedefs.h"


Project	*project_i;

@implementation Project

- (void)viewDidLoad
{
	project_i = self;
}

//===========================================================
//
//	Project code
//
//===========================================================
- initializeVars
{
	char		*s;
	
	s = [preferences_i getProjectPath];
	StripFilename(s);
	strcpy(path_basepath,s);
	
	strcpy(path_progdir,s);
	strcat(path_progdir,"/"SUBDIR_ENT);
	
	strcpy(path_mapdirectory,s);
	strcat(path_mapdirectory,"/"SUBDIR_MAPS);	// source dir

	strcpy(path_finalmapdir,s);
	strcat(path_finalmapdir,"/"SUBDIR_MAPS);	// dest dir
	
	[basepathinfo_i	setStringValue:[NSString stringWithCString:s encoding:[NSString defaultCStringEncoding]]];		// in Project Inspector
	
	#if 0
	if ((s = [projectInfo getStringFor:BASEPATHKEY]))
	{
		strcpy(path_basepath,s);
		
		strcpy(path_progdir,s);
		strcat(path_progdir,"/"SUBDIR_ENT);
		
		strcpy(path_mapdirectory,s);
		strcat(path_mapdirectory,"/"SUBDIR_MAPS);	// source dir

		strcpy(path_finalmapdir,s);
		strcat(path_finalmapdir,"/"SUBDIR_MAPS);	// dest dir
		
		[basepathinfo_i	setStringValue:s];		// in Project Inspector
	}
	#endif
		
	if ((s = [projectInfo getStringFor:BSPFULLVIS]))
	{
		strcpy(string_fullvis,s);
		changeString('@','\"',string_fullvis);
	}
		
	if ((s = [projectInfo getStringFor:BSPFASTVIS]))
	{
		strcpy(string_fastvis,s);
		changeString('@','\"',string_fastvis);
	}
		
	if ((s = [projectInfo getStringFor:BSPNOVIS]))
	{
		strcpy(string_novis,s);
		changeString('@','\"',string_novis);
	}
		
	if ((s = [projectInfo getStringFor:BSPRELIGHT]))
	{
		strcpy(string_relight,s);
		changeString('@','\"',string_relight);
	}
		
	if ((s = [projectInfo getStringFor:BSPLEAKTEST]))
	{
		strcpy(string_leaktest,s);
		changeString('@','\"',string_leaktest);
	}

	if ((s = [projectInfo getStringFor:BSPENTITIES]))
	{
		strcpy(string_entities,s);
		changeString('@','\"', string_entities);
	}

	// Build list of wads	
	wadList = [projectInfo parseMultipleFrom:WADSKEY];

	//	Build list of maps & descriptions
	mapList = [projectInfo parseMultipleFrom:MAPNAMESKEY];
	descList = [projectInfo parseMultipleFrom:DESCKEY];
	[self changeChar:'_' to:' ' in:descList];
	
	[self initializeProjSettings];

	return self;
}

//
//	Init Project Settings fields
//
- initializeProjSettings
{
    [pis_basepath_i	setStringValue:[NSString stringWithCString:path_basepath encoding:[NSString defaultCStringEncoding]]];
	[pis_fullvis_i	setStringValue:[NSString stringWithCString:string_fullvis encoding:[NSString defaultCStringEncoding]]];
	[pis_fastvis_i	setStringValue:[NSString stringWithCString:string_fastvis encoding:[NSString defaultCStringEncoding]]];
	[pis_novis_i	setStringValue:[NSString stringWithCString:string_novis encoding:[NSString defaultCStringEncoding]]];
	[pis_relight_i	setStringValue:[NSString stringWithCString:string_relight encoding:[NSString defaultCStringEncoding]]];
	[pis_leaktest_i	setStringValue:[NSString stringWithCString:string_leaktest encoding:[NSString defaultCStringEncoding]]];
	
	return self;
}

//
//	Add text to the BSP Output window
//
- addToOutput:(char *)string
{
	int	end;
	
	///**************************************************************end = [BSPoutput_i textLength];
	///**************************************************************[BSPoutput_i setSel:end :end];
	///**************************************************************[BSPoutput_i replaceSel:string];
	
	///**************************************************************end = [BSPoutput_i textLength];
	///**************************************************************[BSPoutput_i setSel:end :end];
	///**************************************************************[BSPoutput_i scrollSelToVisible];
	
	return self;
}

- clearBspOutput:sender
{
	[BSPoutput_i	selectAll:self];
	///**************************************************************[BSPoutput_i	replaceSel:"\0"];
	
	return self;
}

- print
{
	///**************************************************************[BSPoutput_i	printPSCode:self];
	return self;
}


- initializeProject
{
	[self parseProjectFile];
	if (projectInfo == NULL)
		return self;
	[self initializeVars];
	///**************************************************************[mapbrowse_i reuseColumns:YES];
	[mapbrowse_i loadColumnZero];
	///**************************************************************[pis_wads_i reuseColumns:YES];
	[pis_wads_i loadColumnZero];

	[things_i		initEntities];
	
	return self;
}

//
//	Change a character to another in a Storage list of strings
//
- changeChar:(char)f to:(char)t in:(id)obj
{
	int	i;
	int	max;
	char	*string;

	max = [obj count];
	for (i = 0;i < max;i++)
	{
		string = [obj pointerAtIndex:i];
		changeString(f,t,string);
	}
	return self;
}

//
//	Fill the QuakeEd Maps or wads browser
//	(Delegate method - delegated in Interface Builder)
//
- (int)browser:sender fillMatrix:matrix inColumn:(int)column
{
	id		cell, list;
	int		max;
	char	*name;
	int		i;

	if (sender == mapbrowse_i)
		list = mapList;
	else if (sender == pis_wads_i)
		list = wadList;
	else
	{
		list = nil;
		Error ("Project: unknown browser to fill");
	}
	
	///**************************************************************max = [list count];
	/*for (i = 0 ; i<max ; i++)
	{
		name = [list elementAt:i];
		[matrix addRow];
		cell = [matrix cellAt:i :0];
		[cell setStringValue:name];
		[cell setLeaf:YES];
		[cell setLoaded:YES];
	}*/
	return i;
}

//
//	Clicked on a map name or description!
//
///**************************************************************- clickedOnMap:sender
/*{
	id	matrix;
	int	row;
	char	fname[1024];
	id	panel;
	
	matrix = [sender matrixInColumn:0];
	row = [matrix selectedRow];
	sprintf(fname,"%s/%s.map",path_mapdirectory,
		(char *)[mapList elementAt:row]);
	
	panel = NXGetAlertPanel("Loading...",
		"Loading map. Please wait.",NULL,NULL,NULL);
	[panel orderFront:NULL];

	[quakeed_i doOpen:fname];

	[panel performClose:NULL];
	NXFreeAlertPanel(panel);
	return self;
}*/


- setTextureWad: (char *)wf
{
	int		i, c;
	char	*name;
	
	qprintf ("loading %s", wf);

// set the row in the settings inspector wad browser
	///**************************************************************c = [wadList count];
	/*for (i=0 ; i<c ; i++)
	{
		name = (char *)[wadList elementAt:i];
		if (!strcmp(name, wf))
		{
			[[pis_wads_i matrixInColumn:0] selectCellAt: i : 0];
			break;
		}
	}

// update the texture inspector
	[texturepalette_i initPaletteFromWadfile:wf ];
	[[map_i objectAt: 0] setKey:"wad" toValue: wf];
//	[inspcontrol_i changeInspectorTo:i_textures];

	[quakeed_i updateAll];*/

	return self;
}

//
//	Clicked on a wad name
//
///**************************************************************- clickedOnWad:sender
/*{
	id		matrix;
	int		row;
	char	*name;
	
	matrix = [sender matrixInColumn:0];
	row = [matrix selectedRow];

	name = (char *)[wadList elementAt:row];
	[self setTextureWad: name];
	
	return self;
}*/


//
//	Read in the <name>.QE_Project file
//
- parseProjectFile
{
	char	*path;
	
	path = [preferences_i getProjectPath];
	if (!path || !path[0] || access(path,0))
	{
        NSAlert* alert = [[NSAlert alloc] init];
        alert.messageText = @"Project Error!";
        alert.informativeText = @"A default project has not been found.";
        [alert addButtonWithTitle:@"Open Project"];
        [alert runModal];
        
		if ([self openProject] == nil)
			while (1)		// can't run without a project
				[NSApp terminate: self];
		return self;	
	}

	[self openProjectFile:path];
	return self;
}

//
//	Loads and parses a project file
//
- openProjectFile:(char *)path
{		
	FILE	*fp;
	struct	stat s;

	strcpy(path_projectinfo,path);

	projectInfo = NULL;
	fp = fopen(path,"r+t");
	if (fp == NULL)
		return self;

	stat(path,&s);
	lastModified = s.st_mtime;

	projectInfo = [(Dict *)[Dict alloc] initFromFile:fp];
	fclose(fp);
	
	return self;
}

- (char *)currentProjectFile
{
	return path_projectinfo;
}

//
//	Open a project file
//
- openProject
{
	char	path[128];
	NSOpenPanel		*openpanel;
	int		rtn;
	char	**filenames;
	char	*dir;
	
	openpanel = [NSOpenPanel openPanel];
    openpanel.allowsMultipleSelection = NO;
    openpanel.canChooseDirectories = NO;
    openpanel.allowedFileTypes = @[ @"qpr" ];
    
    if ([openpanel runModal] == NSModalResponseOK)
    {
        char* path = (char*)openpanel.URLs[0].fileSystemRepresentation;
        strcpy(path_projectinfo,path);
        [self openProjectFile:path];
    
        return self;
    };

    return nil;
}


//
//	Search for a string in a List of strings
//
- (int)searchForString:(char *)str in:(id)obj
{
	int	i;
	int	max;
	char	*s;

	max = [obj count];
	for (i = 0;i < max; i++)
	{
		s = (char *)[obj pointerAtIndex:i];
		if (!strcmp(s,str))
			return 1;
	}
	return 0;
}

- (char *)getMapDirectory
{
	return path_mapdirectory;
}

- (char *)getFinalMapDirectory
{
	return path_finalmapdir;
}

- (char *)getProgDirectory
{
	return path_progdir;
}


//
//	Return the WAD name for cmd-8
//
- (char *)getWAD8
{
	if (!path_wad8[0])
		return NULL;
	return path_wad8;
}

//
//	Return the WAD name for cmd-9
//
- (char *)getWAD9
{
	if (!path_wad9[0])
		return NULL;
	return path_wad9;
}

//
//	Return the WAD name for cmd-0
//
- (char *)getWAD0
{
	if (!path_wad0[0])
		return NULL;
	return path_wad0;
}

//
//	Return the FULLVIS cmd string
//
- (char *)getFullVisCmd
{
	if (!string_fullvis[0])
		return NULL;
	return string_fullvis;
}

//
//	Return the FASTVIS cmd string
//
- (char *)getFastVisCmd
{
	if (!string_fastvis[0])
		return NULL;
	return string_fastvis;
}

//
//	Return the NOVIS cmd string
//
- (char *)getNoVisCmd
{
	if (!string_novis[0])
		return NULL;
	return string_novis;
}

//
//	Return the RELIGHT cmd string
//
- (char *)getRelightCmd
{
	if (!string_relight[0])
		return NULL;
	return string_relight;
}

//
//	Return the LEAKTEST cmd string
//
- (char *)getLeaktestCmd
{
	if (!string_leaktest[0])
		return NULL;
	return string_leaktest;
}

- (char *)getEntitiesCmd
{
	if (!string_entities[0])
		return NULL;
	return string_entities;
}

@end

//====================================================
// C Functions
//====================================================

//
// Change a character to a different char in a string
//
void changeString(char cf,char ct,char *string)
{
	int	j;

	for (j = 0;j < strlen(string);j++)
		if (string[j] == cf)
			string[j] = ct;
}


