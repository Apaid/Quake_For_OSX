
#import "qedefs.h"

ZView *zview_i;

id zscrollview_i, zscalemenu_i, zscalebutton_i;

float	zplane;
float	zplanedir;

@implementation ZView 

/*
==================
initWithFrame:
==================
*/
- initWithFrame:(NSRect)frameRect
{
	NSPoint	pt;
	
	origin[0] = 0.333;
	origin[1] = 0.333;
	
	self = [super initWithFrame: frameRect];
	[self allocateGState];
	[self clearBounds];
	
	zview_i = self;
	scale = 1;
	
//		
// initialize the pop up menus
//
///**************************************************************	zscalemenu_i = [[PopUpList alloc] init];
/*	[zscalemenu_i setTarget: self];
	[zscalemenu_i setAction: @selector(scaleMenuTarget:)];

	[zscalemenu_i addItem: "12.5%"];
	[zscalemenu_i addItem: "25%"];
	[zscalemenu_i addItem: "50%"];
	[zscalemenu_i addItem: "75%"];
	[zscalemenu_i addItem: "100%"];
	[zscalemenu_i addItem: "200%"];
	[zscalemenu_i addItem: "300%"];
	[[zscalemenu_i itemList] selectCellAt: 4 : 0];
	
	zscalebutton_i = NXCreatePopUpListButton(zscalemenu_i);


// initialize the scroll view
	zscrollview_i = [[ZScrollView alloc] 
		initWithFrame: 		frameRect
		button1: 		zscalebutton_i
	];
	[zscrollview_i setAutosizing: NX_WIDTHSIZABLE | NX_HEIGHTSIZABLE];

	[[zscrollview_i setDocView: self] free];

//	[superview setDrawOrigin: 0 : 0];*/

	minheight = 0;
	maxheight = 64;

	pt.x = -self.bounds.size.width;
	pt.y = -128;

	[self newRealBounds];
	
	[self setOrigin: &pt scale: 1];
	
	return zscrollview_i;
}

- setXYOrigin: (NSPoint *)pt
{
	origin[0] = pt->x + 0.333;
	origin[1] = pt->y + 0.333;
	return self;
}

- (float)currentScale
{
	return scale;
}

/*
===================
setOrigin:scale:
===================
*/
- setOrigin: (NSPoint *)pt scale: (float)sc
{
	NSRect		sframe;
	NSRect		newbounds;
	
//
// calculate the area visible in the cliprect
//
	scale = sc;
	
	///**************************************************************[superview getFrame: &sframe];
	///**************************************************************[superview getFrame: &newbounds];
	newbounds.origin = *pt;
	newbounds.size.width /= scale; 
	newbounds.size.height /= scale; 
	
//
// union with the realbounds
//
	if (newbounds.origin.y > oldminheight)
	{
		newbounds.size.height += newbounds.origin.y - oldminheight;
		newbounds.origin.y = oldminheight;
	}
	if (newbounds.origin.y+newbounds.size.height < oldmaxheight)
	{
		newbounds.size.height += oldmaxheight
		 - (newbounds.origin.y + newbounds.size.height);
	}

//
// redisplay everything
//
	///**************************************************************[quakeed_i disableDisplay];

//
// size this view
//
	///**************************************************************[self sizeTo: newbounds.size.width : newbounds.size.height];
	///**************************************************************[self setDrawOrigin: -newbounds.size.width/2 : newbounds.origin.y];
	///**************************************************************[self moveTo: -newbounds.size.width/2 : newbounds.origin.y];
	
//
// scroll and scale the clip view
//
	///**************************************************************[superview setDrawSize
	///**************************************************************	: sframe.size.width/scale
	///**************************************************************	: sframe.size.height/scale];
	///**************************************************************[superview setDrawOrigin: pt->x : pt->y];

	///**************************************************************[quakeed_i reenableDisplay];
	[zscrollview_i display];
	
	return self;
}


/*
====================
scaleMenuTarget:

Called when the scaler popup on the window is used
====================
*/
- scaleMenuTarget: sender
{
	char	const	*item;
	NSRect		visrect, sframe;
	float		nscale;
	
	///**************************************************************item = [[sender selectedCell] title];
	sscanf (item,"%f",&nscale);
	nscale /= 100;
	
	if (nscale == scale)
		return NULL;
		
// keep the center of the view constant
    visrect = self.superview.bounds;
	///**************************************************************[superview getFrame: &sframe];
	visrect.origin.x += visrect.size.width/2;
	visrect.origin.y += visrect.size.height/2;
	
	visrect.origin.x -= sframe.size.width/2/nscale;
	visrect.origin.y -= sframe.size.height/2/nscale;
	
	[self setOrigin: &visrect.origin scale: nscale];
	
	return self;
}


- clearBounds
{
	topbound = 999999;
	bottombound = -999999;

	return self;
}

- getBounds: (float *)top :(float *)bottom;
{
	*top = topbound;
	*bottom = bottombound;
	return self;
}


/*
==================
addToHeightRange:
==================
*/
- addToHeightRange: (float)height
{
	if (height < minheight)
		minheight = height;
	if (height > maxheight)
		maxheight = height;
	return self;
}


/*
==================
newSuperBounds

When superview is resized
==================
*/
- newSuperBounds
{	
	oldminheight++;
	[self newRealBounds];
	
	return self;
}


/*
===================
newRealBounds

Should only change the scroll bars, not cause any redraws.
If realbounds has shrunk, nothing will change.
===================
*/
- newRealBounds
{
	NSRect		sbounds;
	float		vistop, visbottom;

	if (minheight == oldminheight && maxheight == oldmaxheight)
		return self;
		
	oldminheight = minheight;
	oldmaxheight = maxheight;
		
	minheight -= 16;
	maxheight += 16;
	
//
// calculate the area visible in the cliprect
//
    sbounds = self.superview.bounds;
	visbottom = sbounds.origin.y;
	vistop = visbottom + sbounds.size.height;
	
	if (vistop > maxheight)
		maxheight = vistop;
	if (visbottom < minheight)
		minheight = visbottom;
	if (minheight == self.bounds.origin.y && maxheight-minheight == self.bounds.size.height)
		return self;
		
	sbounds.origin.y = minheight;
	sbounds.size.height = maxheight - minheight;

//
// size this view
//
///**************************************************************	[quakeed_i disableDisplay];
/*
	[self suspendNotifyAncestorWhenFrameChanged:YES];
	[self sizeTo: sbounds.size.width : sbounds.size.height];
	[self setDrawOrigin: -sbounds.size.width/2 : sbounds.origin.y];
	[self moveTo: -sbounds.size.width/2 : sbounds.origin.y];
	[self suspendNotifyAncestorWhenFrameChanged:NO];
	[[superview superview] reflectScroll: superview];

	[quakeed_i reenableDisplay];
	
	[[[[self superview] superview] vertScroller] display];*/
	
	return self;
}



/*
============
drawGrid

Draws tile markings every 64 units, and grid markings at the grid scale if
the grid lines are >= 4 pixels apart

Rect is in global world (unscaled) coordinates
============
*/

- drawGrid: (NSRect)dirtyRect
{
///**************************************************************	int		y, stopy;
/*	float	top,bottom;
	int		left, right;
	int		gridsize;
	char	text[10];
	BOOL	showcoords;
	
	showcoords = [quakeed_i showCoordinates];
		
	PSsetlinewidth (0);

	gridsize = [xyview_i gridsize];
	
	left = self.bounds.origin.x;
	right = 24;
	
	bottom = rect->origin.y-1;
	top = rect->origin.y+rect->size.height+2;

//
// grid
//
// can't just divide by grid size because of negetive coordinate
// truncating direction
//
	if (gridsize>= 4/scale)
	{
		y = floor(bottom/gridsize);
		stopy = floor(top/gridsize);
		
		y *= gridsize;
		stopy *= gridsize;
		if (y<bottom)
			y+= gridsize;
			
		beginUserPath (upath,NO);
		
		for ( ; y<=stopy ; y+= gridsize)
			if (y&31)
			{
				UPmoveto (upath, left, y);
				UPlineto (upath, right, y);
			}
	
		endUserPath (upath, dps_ustroke);
		PSsetrgbcolor (0.8,0.8,1.0);	// thin grid color
		sendUserPath (upath);
	}

//
// half tiles
//
	y = floor(bottom/32);
	stopy = floor(top/32);
	
	if ( ! (((int)y + 4096) & 1) )
		y++;
	y *= 32;
	stopy *= 32;
	if (stopy >= top)
		stopy -= 32;
	
	beginUserPath (upath,NO);
	
	for ( ; y<=stopy ; y+= 64)
	{
		UPmoveto (upath, left, y);
		UPlineto (upath, right, y);
	}

	endUserPath (upath, dps_ustroke);
	PSsetgray (12.0/16.0);
	sendUserPath (upath);

//
// tiles
//
	y = floor(bottom/64);
	stopy = floor(top/64);
	
	y *= 64;
	stopy *= 64;
	if (y<bottom)
		y+= 64;
	if (stopy >= top)
		stopy -= 64;
		
	beginUserPath (upath,NO);
	PSsetgray (0);		// for text
	PSselectfont("Helvetica-Medium",10/scale);
	PSrotate(0);
	
	for ( ; y<=stopy ; y+= 64)
	{
		if (showcoords)
		{
			sprintf (text, "%i",y);
			PSmoveto(left,y);
			PSshow(text);
		}
		UPmoveto (upath, left+24, y);
		UPlineto (upath, right, y);
	}

// divider
	UPmoveto (upath, 0, bounds.origin.y);
	UPlineto (upath, 0, bounds.origin.y + bounds.size.height);
	
	endUserPath (upath, dps_ustroke);
	PSsetgray (10.0/16.0);
	sendUserPath (upath);

//
// origin
//
	PSsetlinewidth (5);
	PSsetgray (4.0/16.0);
	PSmoveto (right,0);
	PSlineto (left,0);
	PSstroke ();
	PSsetlinewidth (0.15);*/
		
	return self;
}


- drawZplane
{
	///**************************************************************PSsetrgbcolor (0.2, 0.2, 0);
	/*PSarc (0, zplane, 4, 0, M_PI*2);
	PSfill ();*/
	return self;
}

/*
===============================================================================
drawRect
===============================================================================
*/

- (void)drawRect:(NSRect)dirtyRect
{
///**************************************************************	NSRect		visRect;
/*
	minheight = 999999;
	maxheight = -999999;

// allways draw the entire bar	
	[self getVisibleRect:&visRect];
	rects = &visRect;

// erase window
	NXEraseRect (dirtyRect);
	
// draw grid
	[self drawGrid: dirtyRect];
	
// draw zplane
//	[self drawZplane];
	
// draw all entities
	[map_i makeUnselectedPerform: @selector(ZDrawSelf)];

// possibly resize the view
	[self newRealBounds];*/
}

/*
==============
XYDrawSelf
==============
*/
- XYDrawSelf
{
	///**************************************************************PSsetrgbcolor (0,0.5,1.0);
	/*PSsetlinewidth (0.15);
	PSmoveto (origin[0]-16, origin[1]-16);
	PSrlineto (32,32);
	PSmoveto (origin[0]-16, origin[1]+16);
	PSrlineto (32,-32);
	PSstroke ();*/

	return self;
}


/*
==============
getPoint: (NSPoint *)pt
==============
*/
- getPoint: (NSPoint *)pt
{
	pt->x = origin[0] + 0.333;	// offset a bit to avoid edge cases
	pt->y = origin[1] + 0.333;
	return self;
}

- setPoint: (NSPoint *)pt
{
	origin[0] = pt->x;
	origin[1] = pt->y;
	return self;
}


/*
==============================================================================

MOUSE CLICKING

==============================================================================
*/


/*
================
dragLoop:
================
*/
static	NSPoint		oldreletive;
- dragFrom: (NSEvent *)startevent 
	useGrid: (BOOL)ug
	callback: (void (*) (float dy)) callback
{
	NSEvent		*event;
	NSPoint		startpt, newpt;
	NSPoint		reletive, delta;
	int		gridsize;

	gridsize = [xyview_i gridsize];
	
	startpt = [NSEvent mouseLocation];
	[self convertPoint:startpt  fromView:NULL];
	
	oldreletive.x = oldreletive.y = 0;
	
	///**************************************************************while (1)
	/*{
		event = [NXApp getNextEvent:
			NX_LMOUSEUPMASK | NX_LMOUSEDRAGGEDMASK
			| NX_RMOUSEUPMASK | NX_RMOUSEDRAGGEDMASK];
		if (event->type == NX_LMOUSEUP || event->type == NX_RMOUSEUP)
			break;
			
		newpt = event->location;
		[self convertPoint:newpt  fromView:NULL];

		reletive.y = newpt.y - startpt.y;
		
		if (ug)
		{	// we want truncate towards 0 behavior here
			reletive.y = gridsize * (int)(reletive.y / gridsize);
		}

		if (reletive.y == oldreletive.y)
			continue;

		delta.y = reletive.y - oldreletive.y;
		oldreletive = reletive;			
		callback (delta.y);		
	}*/

	return self;
}

//============================================================================


void ZDragCallback (float dy)
{
	sb_translate[0] = 0;
	sb_translate[1] = 0;
	sb_translate[2] = dy;

	[map_i makeSelectedPerform: @selector(translate)];
	
	[quakeed_i redrawInstance];
}

- selectionDragFrom: (NSEvent*)theEvent	
{
	qprintf ("dragging selection");
	[self	dragFrom:	theEvent 
			useGrid:	YES
			callback:	ZDragCallback ];
	[quakeed_i updateCamera];
	qprintf ("");
	return self;
	
}

//============================================================================

void ZScrollCallback (float dy)
{
	NSRect		basebounds;
	NSPoint		neworg;
	float		scale;
	
	basebounds = [ [zview_i superview] bounds];
    basebounds = [zview_i convertRect:basebounds fromView:[zview_i superview]];

	neworg.y = basebounds.origin.y - dy;
	
	scale = [zview_i currentScale];
	
	oldreletive.y -= dy;
	[zview_i setOrigin: &neworg scale: scale];
}

- scrollDragFrom: (NSEvent*)theEvent	
{
	qprintf ("scrolling view");
	[self	dragFrom:	theEvent 
			useGrid:	YES
			callback:	ZScrollCallback ];
	qprintf ("");
	return self;
}

//============================================================================

void ZControlCallback (float dy)
{
	int		i;
	
	for (i=0 ; i<numcontrolpoints ; i++)
		controlpoints[i][2] += dy;
	
	[[map_i selectedBrush] calcWindings];	
	[quakeed_i redrawInstance];
}

- (BOOL)planeDragFrom: (NSEvent*)theEvent	
{
	NSPoint			pt;
	vec3_t			dragpoint;
	
	if ([map_i numSelected] != 1)
		return NO;

	pt= [NSEvent mouseLocation];
	[self convertPoint:pt  fromView:NULL];

	dragpoint[0] = origin[0];
	dragpoint[1] = origin[1];
	dragpoint[2] = pt.y;
	
	///**************************************************************[[map_i selectedBrush] getZdragface: dragpoint];
	if (!numcontrolpoints)
		return NO;
	
	qprintf ("dragging brush plane");
	
	pt= [NSEvent mouseLocation];
	[self convertPoint:pt  fromView:NULL];

	[self	dragFrom:	theEvent 
			useGrid:	YES
			callback:	ZControlCallback ];
			
	///**************************************************************[[map_i selectedBrush] removeIfInvalid];
	
	[quakeed_i updateCamera];
	qprintf ("");
	return YES;
}


//============================================================================

/*
===================
mouseDown
===================
*/
- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint	pt;
	int		flags;
	vec3_t	p1;
	
	pt= [NSEvent mouseLocation];
	[self convertPoint:pt  fromView:NULL];

	p1[0] = origin[0];
	p1[1] = origin[1];
	p1[2] = pt.y;
	
	flags = theEvent.modifierFlags & (NSShiftKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSCommandKeyMask);

//
// shift click to select / deselect a brush from the world
//
	if (flags == NSShiftKeyMask)
	{		
		[map_i selectRay: p1 : p1 : NO];
		return;
	}
		
//
// alt click = set entire brush texture
//
	if (flags == NSAlternateKeyMask)
	{
		[map_i setTextureRay: p1 : p1 : YES];
		return;
	}

//
// control click = position view
//
	if (flags == NSControlKeyMask)
	{
		[cameraview_i setZOrigin: pt.y];
		[quakeed_i updateAll];
		[cameraview_i ZmouseDown: &pt flags:theEvent.modifierFlags];
		return;
	}

//
// bare click to drag icons or new brush drag
//
	if ( flags == 0 )
	{
// check eye
		if ( [cameraview_i ZmouseDown: &pt flags:theEvent.modifierFlags] )
			return;
			
		if ([map_i numSelected])
		{
			if ( pt.x > 0)
			{
				if ([self planeDragFrom: theEvent])
					return;
			}
			[self selectionDragFrom: theEvent];
			return;
		}

	}
		
	qprintf ("bad flags for click");
	NopSound ();
}

/*
===================
rightMouseDown
===================
*/
- (void)rightMouseDown:(NSEvent *)theEvent
{
	NSPoint	pt;
	int		flags;
		
	pt= [NSEvent mouseLocation];
	[self convertPoint:pt  fromView:NULL];

	flags = theEvent.modifierFlags & (NSShiftKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSCommandKeyMask);

	
//
// click = scroll view
//
	if (flags == 0)
	{
		[self scrollDragFrom: theEvent];
        return;
	}

	qprintf ("bad flags for click");
	NopSound ();
}


/*
===============================================================================

						XY mouse view methods

===============================================================================
*/

/*
================
modalMoveLoop
================
*/
- modalMoveLoop: (NSPoint *)basept :(vec3_t)movemod : converter
{
	vec3_t		originbase;	
	NSEvent		*event;
	NSPoint		newpt;
	vec3_t		delta;
	
	int			i;
	
	VectorCopy (origin, originbase);	
	
//
// modal event loop using instance drawing
//
///**************************************************************	goto drawentry;
/*
	while (event->type != NX_LMOUSEUP)
	{
		//
		// calculate new point
		//
		newpt = event->location;
		[converter convertPoint:&newpt  fromView:NULL];
				
		delta[0] = newpt.x-basept->x;
		delta[1] = newpt.y-basept->y;
		delta[2] = delta[1];		// height change
		
		for (i=0 ; i<3 ; i++)
			origin[i] = originbase[i]+movemod[i]*delta[i];
		
					
drawentry:
		//
		// instance draw new frame
		//
		[quakeed_i newinstance];
		[self display];
		NXPing ();
				
		event = [NXApp getNextEvent: 
			NX_LMOUSEUPMASK | NX_LMOUSEDRAGGEDMASK];		
	}*/

//
// draw the brush back into the window buffer
//
//	[xyview_i display];
	
	return self;
}

/*
===============
XYmouseDown
===============
*/
- (BOOL)XYmouseDown: (NSPoint *)pt
{	
	vec3_t		movemod;
	
	if (fabs(pt->x - origin[0]) > 16
	|| fabs(pt->y - origin[1]) > 16)
		return NO;
		
	movemod[0] = 1;
	movemod[1] = 1;
	movemod[2] = 0;
	
	[self modalMoveLoop: pt : movemod : xyview_i];
	
	return YES;
}

@end