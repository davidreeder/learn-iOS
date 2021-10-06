//
// Dump.m
//
// Output things.  Be useful, and brief.
//
// CLASS METHODS--
//   post:title:
//   post:
//   sep
// 
//   o:
//   objs:
//   sp:
//   s:
//   r:
//   p:
//   z:
//   c:
// 
//   lp:o:
//   lp:objs:
//   lp:r:
//   lp:p:
//   lp:z:
//   lp:c:
//
//   l:o:
//   l:objs:
//   l:r:
//   l:p:
//   l:z:
//   l:c:
// 
//   strAttr:
//   strAttr:index:
//
//   dict:withHeader:matchingPrefix:
//   dict:withHeader:
//
//   inMethod:ofClass:withMessage:
//   inMethod:withMessage:
//   inMethod:
//
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#import "Dump.h"



//---------------------------------------------------- -o--
@implementation Dump

// 
// class methods
//

//------------------- -o-
// post:title:
// post:
// sep
//

+ (void) post: (NSString *)msg   
        title: (NSString *)title
{
  NSLog(@"%@ :: %@", title, msg);
} 

+ (void) post: (NSString *)msg   
{
  [self post:msg title:@"DUMP"];
} 

+ (void) sep
{
  NSLog(@"DUMP --------------------------------------------- -o-");
}



//------------------- -o-
// o:
// objs:
// sp:
//

+ (void) o:(id)obj
{
  [self post:[NSString stringWithFormat:@"%@", obj]];
} 

+ (void) objs:(NSArray *)objects
{
  [self post:[objects componentsJoinedByString:@"  "]];
} 

+ (void) sp:(NSString *)str
{
  [self post:[Dump s:str]];
}



//------------------- -o-
// s:
// r:
//
// p:
// z:
// c:
//

+ (NSString *) s:(NSString *)str
{
  return [NSString stringWithFormat:@"(%d) \"%@\"", [str length], str];
}

+ (NSValue *) r:(NSRange)range
{
  return [NSValue valueWithRange:range];
}


+ (NSValue *) p:(CGPoint)point
{
  return [NSValue valueWithCGPoint:point];
}


+ (NSValue *) z:(CGSize)size
{
  return [NSValue valueWithCGSize:size];
}


+ (NSValue *) c:(CGRect)rect
{
  return [NSValue valueWithCGRect:rect];
}



//------------------- -o-
// lp:o:
// lp:objs:
// lp:r:
//
// lp:p:
// lp:z:
// lp:c:
//

+ (void) lp:(NSString *)label  o:(id)obj
{
  [self post:[Dump l:label o:obj]];
}

+ (void) lp:(NSString *)label  objs:(NSArray *)array
{
  [self post:[Dump l:label objs:array]];
}

+ (void) lp:(NSString *)label  r:(NSRange)range
{
  [self post: [Dump l:label r:range]];
}


+ (void) lp:(NSString *)label  p:(CGPoint)point
{
  [self post: [Dump l:label p:point]];
}

+ (void) lp:(NSString *)label  z:(CGSize)size
{
  [self post: [Dump l:label z:size]];
}

+ (void) lp:(NSString *)label  c:(CGRect)rect
{
  [self post: [Dump l:label c:rect]];
}



//------------------- -o-
// l:o:
// l:objs:
// l:r:
//
// l:p:
// l:z:
// l:c:
//

+ (NSString *) l:(NSString *)label  o:(id)obj
{
  return [NSString stringWithFormat:@"%@=%@", label, obj];
}

+ (NSString *) l:(NSString *)label  objs:(NSArray *)objects
{
  NSMutableArray *ma = [objects mutableCopy];
  [ma insertObject:[label stringByAppendingFormat:@" -->"] atIndex:0 ];
  return [ma componentsJoinedByString:@" "];
}

+ (NSString *) l:(NSString *)label  r:(NSRange)range 
{
  return [NSString stringWithFormat:@"%@=(%u,%u)", 
           label, range.location, range.length];
}


+ (NSString *) l:(NSString *)label  p:(CGPoint)point 
{
  return [NSString stringWithFormat:@"%@=(%0.1f,%0.1f)", 
           label, point.x, point.y];
}

+ (NSString *) l:(NSString *)label  z:(CGSize)size 
{
  return [NSString stringWithFormat:@"%@=(%0.1f,%0.1f)", 
           label, size.width, size.height];
}

+ (NSString *) l:(NSString *)label  c:(CGRect)rect 
{
  return [NSString stringWithFormat:@"%@=((%0.1f,%0.1f) (%0.1f,%0.1f))", 
           label, 
           rect.origin.x, rect.origin.x,
           rect.size.width, rect.size.height];
}




//------------------- -o-
// strAttr:
// strAttr:index:
//

+ (void)strAttr:(NSAttributedString *)str  
{
  [Dump strAttr:str index:0];
}


+ (void)strAttr:(NSAttributedString *)str  index:(NSUInteger)index
{
  NSDictionary        *dict;
  NSRange              effectiveRange, longestRange;


  // Poll attributes from longest length of str.
  //
  longestRange = NSMakeRange(index, [str length] - index);

  // NB  Raises an NSRangeException if index or any part of rangeLimit
  //     lies beyond the end of the receivers characters.
  //
  dict = [str  attributesAtIndex:  index  
           longestEffectiveRange: &effectiveRange
                         inRange:  longestRange
         ];


  // Dictionary dump header info.
  //
  NSString *scribble = 
    [NSString stringWithFormat:@"ATTRIBUTED STRING :: \"%@\"\n\t:: index=%d length=%d",
      [str string], index, NSMaxRange(effectiveRange)];

  if (NSMaxRange(effectiveRange) < NSMaxRange(longestRange)) 
  {
    scribble = [scribble stringByAppendingFormat:@" limit=%d", 
                 NSMaxRange(longestRange)];
  }

  [Dump post:scribble];


  // Dictionary dump attributes.
  //
  [Dump dict:dict withHeader:@"(ATTRIBUTED STRING)" matchingPrefix:nil];

} // strAttr:index:



//------------------- -o-
// dict:withHeader:
// dict:withHeader:matchingPrefix:
//
// ASSUMES  Dictionary keys are NSStrings!
//
// TBD  Ignore non-NSStrings?  (print a count of ignored items)
//
+ (void)      dict: (NSDictionary *)dict  
        withHeader: (NSString *)header
    matchingPrefix: (NSString *)prefix 
{
  NSString *title = header ? header : @"(unnamed)";
  title = DP_STRWFMT(@"_DICTIONARY: %@_", title);


  NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingComparator:DP_BLOCK_CMPSTR];

  if (!sortedKeys) {
    [Dump post: [NSString stringWithFormat:@"(empty dictionary)"]
         title: title
    ];

  } else {
    for (id key in sortedKeys) {
      if (prefix && [key isKindOfClass:[NSString class]]) {
        if (! [key hasPrefix:prefix])  { 
          continue; 
        }
      }

      id value = [dict objectForKey:key];
      [Dump post: [NSString stringWithFormat:@"%@ : %@", key, value]
           title: title
      ];
    }
  }

} // dict:withHeader:matchingPrefix: 



+ (void)      dict: (NSDictionary *)dict                // ALIAS
        withHeader: (NSString *)header
{
  [Dump dict:dict withHeader:header matchingPrefix:nil];
}




//------------------- -o-
+ (void) inMethod: (NSString *)method 
          ofClass: (NSString *)class
      withMessage: (id)message
{
  NSString *output   = @"";
  NSString *category = @"_IN METHOD_";

  if (class) {
    output = [output stringByAppendingFormat:@"%@ :: ", class];
  }

  output = [output stringByAppendingFormat:@"%@", method];

  if (message) {
    output   = [output stringByAppendingFormat:@" -- %@", message];
    category = @"DUMP";
  }

  [self post:output title:category];
}


//------------------- -o-
+ (void) inMethod: (NSString *)method           // ALIAS
      withMessage: (id)message
{
  [self inMethod:method ofClass:nil withMessage:message];
}


//------------------- -o-
+ (void) inMethod: (NSString *)method           // ALIAS
{
  [self inMethod:method ofClass:nil withMessage:nil];
}


@end // Dump

