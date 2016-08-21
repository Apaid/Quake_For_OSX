
#import "qedefs.h"

Things	*things_i;

@implementation Things
{
    __weak IBOutlet NSButton *flags_00_i;
    __weak IBOutlet NSButton *flags_10_i;
    __weak IBOutlet NSButton *flags_20_i;
    __weak IBOutlet NSButton *flags_30_i;
    __weak IBOutlet NSButton *flags_01_i;
    __weak IBOutlet NSButton *flags_11_i;
    __weak IBOutlet NSButton *flags_21_i;
    __weak IBOutlet NSButton *flags_31_i;
    __weak IBOutlet NSButton *flags_02_i;
    __weak IBOutlet NSButton *flags_12_i;
    __weak IBOutlet NSButton *flags_22_i;
    __weak IBOutlet NSButton *flags_32_i;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	things_i = self;
	lastSelected = 0;

    NSMutableArray<NSButton*> *list = [[NSMutableArray<NSButton*> alloc] init];
    
    [list addObject:flags_00_i];
    [list addObject:flags_10_i];
    [list addObject:flags_20_i];
    [list addObject:flags_30_i];
    [list addObject:flags_01_i];
    [list addObject:flags_11_i];
    [list addObject:flags_21_i];
    [list addObject:flags_31_i];
    [list addObject:flags_02_i];
    [list addObject:flags_12_i];
    [list addObject:flags_22_i];
    [list addObject:flags_32_i];
    
    flags_i = list;
}

//
//	Load the TEXT object with the entity comment
//
- loadEntityComment:(EntityClass*)obj
{
    [entity_comment_i.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithCString:[obj comments] encoding:[NSString defaultCStringEncoding]]]];

	return self;
}


- initEntities
{	
	char	*path;

	path = [project_i getProgDirectory];

    [prog_path_i setStringValue: [NSString stringWithCString:path encoding:[NSString defaultCStringEncoding]]];
	
	[[EntityClassList alloc] initForSourceDirectory: path];

	///**************************************************************[self loadEntityComment:[entity_classes_i objectAtIndex:lastSelected]];
	[entity_browser_i loadColumnZero];
	[[entity_browser_i matrixInColumn:0] selectCellAtRow:lastSelected column:0];

	[entity_browser_i setDoubleAction: @selector(doubleClickEntity:)];
	
	return self;
}

- selectEntity: sender
{
	id		matr;
	
	matr = [sender matrixInColumn: 0];
	lastSelected = [matr selectedRow];
	[self loadEntityComment:[entity_classes_i objectAtIndex:lastSelected]];
	[quakeed_i makeFirstResponder: quakeed_i];
	
	return self;
}

- doubleClickEntity: sender
{
	[map_i makeEntity: sender];
	[quakeed_i makeFirstResponder: quakeed_i];
	return self;
}

- (char *)spawnName
{
	return [[entity_classes_i objectAtIndex:lastSelected] classname];
}


//
//	Flush entity classes & reload them!
//
- reloadEntityClasses: sender
{
	EntityClass *ent;
	char	*path;
	
	path = (char *)[[prog_path_i stringValue] cStringUsingEncoding:[NSString defaultCStringEncoding]];
	if (!path || !path[0])
	{
		path = [project_i getProgDirectory];
        [prog_path_i setStringValue: [NSString stringWithCString:path encoding:[NSString defaultCStringEncoding]]];
	}
	
	//	Free all entity info in memory...
	[entity_classes_i removeAllObjects];
	
	//	Now, RELOAD!
	[[EntityClassList alloc] initForSourceDirectory: path];

	lastSelected = 0;
	ent = [entity_classes_i objectAtIndex:lastSelected];
	[self loadEntityComment:[entity_classes_i objectAtIndex:lastSelected]];

	[entity_browser_i loadColumnZero];
	[[entity_browser_i matrixInColumn:0] selectCellAtRow:lastSelected column:0];

	[self newCurrentEntity];	// in case flags changed
	
	return self;
}


- selectClass: (char *)class
{
	id		classent;
		
	classent = [entity_classes_i classForName:class];
	if (!classent)
		return self;
	lastSelected = [entity_classes_i indexOfObject: classent];
	
	if (lastSelected < 0)
		lastSelected = 0;
		
	[self loadEntityComment:classent];
	[[entity_browser_i matrixInColumn:0] selectCellAtRow:lastSelected column:0];
	[[entity_browser_i matrixInColumn:0] scrollCellToVisibleAtRow:lastSelected column:0];

	return self;
}


- newCurrentEntity
{
	id		ent, classent, cell;
	char	*classname;
	int		r, c;
	char	*flagname;
	int		flags;
	
	ent = [map_i currentEntity];
	classname = [ent valueForQKey: "classname"];
	if (ent != [map_i objectAtIndex: 0])
		[self selectClass: classname];	// don't reset for world
	classent = [entity_classes_i classForName:classname];
	flagname = [ent valueForQKey: "spawnflags"];
	if (!flagname)
		flags = 0;
	else
		flags = atoi(flagname);
	
	///**************************************************************[flags_i setAutodisplay: NO];
	for (r=0 ; r<4 ; r++)
		for (c=0 ; c<3 ; c++)
		{
			cell = [flags_i objectAtIndex:c*4 + r];
			if (c < 2)
			{
				flagname = [classent flagName: c*4 + r];
                [cell setTitle: [NSString stringWithCString:flagname encoding:[NSString defaultCStringEncoding]]];
			}
			[cell setState: (flags & (1<< ((c*4)+r)) ) > 0];
		}
	///**************************************************************[flags_i setAutodisplay: YES];
	///**************************************************************[flags_i display];
	
//	[keyInput_i setStringValue: ""];
//	[valueInput_i setStringValue: ""];

	///**************************************************************[keypairview_i calcViewSize];
	///**************************************************************[keypairview_i display];
	
	[quakeed_i makeFirstResponder: quakeed_i];
	return self;
}

//
//	Clicked in the Keypair view - set as selected
//
- setSelectedKey:(epair_t *)ep;
{
    [keyInput_i setStringValue:[NSString stringWithCString:ep->key encoding:[NSString defaultCStringEncoding]]];
	[valueInput_i setStringValue:[NSString stringWithCString:ep->value encoding:[NSString defaultCStringEncoding]]];
	[valueInput_i	selectText:self];
	return self;
}

- clearInputs
{
//	[keyInput_i setStringValue: ""];
//	[valueInput_i setStringValue: ""];
	
	[quakeed_i makeFirstResponder: quakeed_i];
	return self;
}

//
//	Action methods
//

///**************************************************************-addPair:sender
/*{
	char	*key, *value;
	
	key = (char *)[keyInput_i stringValue];
	value = (char *)[valueInput_i stringValue];
	
	[ [map_i currentEntity] setKey: key toValue: value ];

	[keypairview_i calcViewSize];
	[keypairview_i display];

	[self clearInputs];
	[quakeed_i updateXY];
	
	return self;
}

-delPair:sender
{
	[quakeed_i makeFirstResponder: quakeed_i];

	[ [map_i currentEntity] removeKeyPair: (char *)[keyInput_i stringValue] ];

	[keypairview_i calcViewSize];
	[keypairview_i display];

	[self clearInputs];

	[quakeed_i updateXY];

	return self;
}*/


//
//	Set the key/value fields to "angle <button value>"
//
- setAngle:sender
{
	const char *title;
	char	value[10];
	
	///**************************************************************title = [[sender selectedCell] title];
	if (!strcmp(title,"Up"))
		strcpy (value, "-1");
	else if (!strcmp(title,"Dn"))
		strcpy (value, "-2");
	else
		strcpy (value, title);
	
	[keyInput_i setStringValue:@"angle"];
    [valueInput_i setStringValue:[NSString stringWithCString:value encoding:[NSString defaultCStringEncoding]]];
	///**************************************************************[self addPair:NULL];
	
	[self clearInputs];

	[quakeed_i updateXY];
	
	return self;
}

///**************************************************************- setFlags:sender
/*{
	int		flags;
	int		r, c, i;
	id		cell;
	char	str[20];
	
	[self clearInputs];
	flags = 0;

	for (r=0 ; r<4 ; r++)
		for (c=0 ; c<3 ; c++)
		{
			cell = [flags_i cellAt: r : c];
			i = ([cell intValue] > 0);
			flags |= (i<< ((c*4)+r));
		}
	
	if (!flags)
		[[map_i currentEntity] removeKeyPair: "spawnflags"];
	else
	{
		sprintf (str, "%i", flags);
		[[map_i currentEntity] setKey: "spawnflags" toValue: str];
	}
	
	[keypairview_i calcViewSize];
	[keypairview_i display];

	return self;
}*/


//
//	Fill the Entity browser
//	(Delegate method - delegated in Interface Builder)
//
///**************************************************************- (int)browser:sender fillMatrix:matrix inColumn:(int)column
/*{
	id		cell;
	int		max;
	int		i;
	id		object;
	
	max = [entity_classes_i count];
	i = 0;
	while(max--)
	{
		object = [entity_classes_i objectAt:i];
		[matrix addRow];
		cell = [matrix cellAt:i++ :0];
		[cell setStringValue:[object classname]];
		[cell setLeaf:YES];
		[cell setLoaded:YES];
	}
	return i;
}*/

@end
