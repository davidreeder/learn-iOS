//
// Dump.h
//
//---------------------------------------------------------------------
//     Copyright David Reeder 2013.  ios@mobilesound.org
//     Distributed under the Boost Software License, Version 1.0.
//     (See ./LICENSE_1_0.txt or http://www.boost.org/LICENSE_1_0.txt)
//---------------------------------------------------------------------

#define DP_VERSION_DUMP  0.5


#import "Danaprajna.h"



//---------------------------------------------------- -o-
@interface Dump : NSObject

  // Post string or separator.
  //
  + (void)       post:(NSString *)msg   title:(NSString *)title;
  + (void)       post:(NSString *)msg;
  + (void)       sep;                                         // separator



  // Post object(s).
  //
  + (void)       o:(id)obj;                                   // one object
  + (void)       objs:(NSArray *)objects;                     // objects

  + (void)       sp:(NSString *)str;                          // string



  // Return some object.
  //
  + (NSString *) s:(NSString *)str;                          // string
  + (NSValue *)  r:(NSRange)range;                           // NSRange

  + (NSValue *)  p:(CGPoint)point;                           // CGPoint
  + (NSValue *)  z:(CGSize)size;                             // CGSize
  + (NSValue *)  c:(CGRect)rect;                             // CGRect



  // Label and POST, one or more object.
  //
  + (void)       lp:(NSString *)label  o:(NSObject *)object;  // one object
  + (void)       lp:(NSString *)label  objs:(NSArray *)array; // objects

  + (void)       lp:(NSString *)label  r:(NSRange)range;      // NSRange

  + (void)       lp:(NSString *)label  p:(CGPoint)point;      // CGPoint
  + (void)       lp:(NSString *)label  z:(CGSize)size;        // CGSize
  + (void)       lp:(NSString *)label  c:(CGRect)rect;        // CGRect

#define DP_DUMPLPO(obj)   [Dump lp:@ #obj  o:obj]
#define DP_DUMPLPN(obj)   [Dump lp:@ #obj  o:@(obj)]

#define DP_DUMPLPR(obj)   [Dump lp:@ #obj  r:obj]
#define DP_DUMPLPP(obj)   [Dump lp:@ #obj  p:obj]
#define DP_DUMPLPZ(obj)   [Dump lp:@ #obj  z:obj]
#define DP_DUMPLPC(obj)   [Dump lp:@ #obj  c:obj]



  // Label and RETURN as NSString, one or more object.
  //
  + (NSString *) l:(NSString *)label  o:(NSObject *)object;  // one object
  + (NSString *) l:(NSString *)label  objs:(NSArray *)array; // objects

  + (NSString *) l:(NSString *)label  r:(NSRange)range;      // NSRange

  + (NSString *) l:(NSString *)label  p:(CGPoint)point;      // CGPoint
  + (NSString *) l:(NSString *)label  z:(CGSize)size;        // CGSize
  + (NSString *) l:(NSString *)label  c:(CGRect)rect;        // CGRect

#define DP_DUMPLO(obj)   [Dump l:@ #obj  o:obj]
#define DP_DUMPLN(obj)   [Dump l:@ #obj  o:@(obj)]

#define DP_DUMPLR(obj)   [Dump l:@ #obj  r:obj]
#define DP_DUMPLP(obj)   [Dump l:@ #obj  p:obj]
#define DP_DUMPLZ(obj)   [Dump l:@ #obj  z:obj]
#define DP_DUMPLC(obj)   [Dump l:@ #obj  c:obj]



  // Dump NSAttributedString (at index).
  //
  + (void) strAttr: (NSAttributedString *)str;
  + (void) strAttr: (NSAttributedString *)str  index: (NSUInteger)index;



  // Dump arbitrary dictionary with NSStrings for keys.
  // Filter on keys matching prefix.
  //
  + (void)      dict: (NSDictionary *)dict  
          withHeader: (NSString *)header
      matchingPrefix: (NSString *)prefix;

  + (void)      dict: (NSDictionary *)dict  
          withHeader: (NSString *)header;


  // Dump marker point within a given method/class + (optional) message.
  //
  + (void) inMethod: (NSString *) method
            ofClass: (NSString *) class
        withMessage: (id)         message;

  + (void) inMethod: (NSString *) method
        withMessage: (id)         message;

  + (void) inMethod: (NSString *) method;

#define DP_MARK_M(method, message)                              \
          [Dump inMethod: @ #method                             \
                 ofClass: NSStringFromClass([self class])       \
             withMessage: message]

#define DP_MARK(method)   DP_MARK_M(method, nil)

#define DP_MARKB(method)  DP_MARK_M(method, @"BEGIN")
#define DP_MARKE(method)  DP_MARK_M(method, @"END")


@end // Dump

