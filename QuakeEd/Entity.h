
#define	MAX_KEY		64
#define	MAX_VALUE	128
typedef struct epair_s
{
	struct epair_s	*next;
	char	key[MAX_KEY];
	char	value[MAX_VALUE];
} epair_t;

// an Entity is a list of brush objects, with additional key / value info

@interface Entity : NSObject<NSCopying>
{
	epair_t	*epairs;
	BOOL	modifiable;
}

- initClass: (char *)classname;
- initFromTokens;

- (void)dealloc;

- (BOOL)modifiable;
- setModifiable: (BOOL)m;

- (char *)targetname;

- writeToFILE: (FILE *)f region:(BOOL)reg;

- (char *)valueForQKey: (char *)k;
- getVector: (vec3_t)v forKey: (char *)k;
- setKey:(char *)k toValue:(char *)v;
- (int)numPairs;
- (epair_t *)epairs;
- removeKeyPair: (char *)key;
- removeObject:(id)o;

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeAllObjects;
- (void)addObject:(id)object;

@end


