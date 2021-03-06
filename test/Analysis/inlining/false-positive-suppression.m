// RUN: %clang_cc1 -analyze -analyzer-checker=core -analyzer-config suppress-null-return-paths=false -verify %s
// RUN: %clang_cc1 -analyze -analyzer-checker=core -verify -DSUPPRESSED=1 %s
// RUN: %clang_cc1 -analyze -analyzer-checker=core -analyzer-config avoid-suppressing-null-argument-paths=true -DSUPPRESSED=1 -DNULL_ARGS=1 -verify %s

#ifdef SUPPRESSED
// expected-no-diagnostics
#endif

@interface PointerWrapper
- (int *)getPtr;
- (id)getObject;
@end

id getNil() {
  return 0;
}

void testNilReceiverHelperA(int *x) {
  *x = 1;
#ifndef SUPPRESSED
  // expected-warning@-2 {{Dereference of null pointer}}
#endif
}

void testNilReceiverHelperB(int *x) {
  *x = 1;
#ifndef SUPPRESSED
  // expected-warning@-2 {{Dereference of null pointer}}
#endif
}

void testNilReceiver(int coin) {
  id x = getNil();
  if (coin)
    testNilReceiverHelperA([x getPtr]);
  else
    testNilReceiverHelperB([[x getObject] getPtr]);
}

// FALSE NEGATIVES (over-suppression)

__attribute__((objc_root_class))
@interface SomeClass
-(int *)methodReturningNull;

@property(readonly) int *propertyReturningNull;

@property(readonly) int *synthesizedProperty;

@end

@implementation SomeClass
-(int *)methodReturningNull {
  return 0;
}

-(int *)propertyReturningNull {
  return 0;
}
@end

void testMethodReturningNull(SomeClass *sc) {
  int *result = [sc methodReturningNull];
  *result = 1;
#ifndef SUPPRESSED
  // expected-warning@-2 {{Dereference of null pointer}}
#endif
}

void testPropertyReturningNull(SomeClass *sc) {
  int *result = sc.propertyReturningNull;
  *result = 1;
#ifndef SUPPRESSED
  // expected-warning@-2 {{Dereference of null pointer}}
#endif
}

void testSynthesizedPropertyReturningNull(SomeClass *sc) {
  if (sc.synthesizedProperty)
    return;

  int *result = sc.synthesizedProperty;
  *result = 1;
#ifndef SUPPRESSED
  // expected-warning@-2 {{Dereference of null pointer}}
#endif
}
