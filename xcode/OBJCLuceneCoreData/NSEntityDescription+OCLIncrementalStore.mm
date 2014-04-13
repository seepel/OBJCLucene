//
//  NSEntityDescription+OCLIncrementalStore.m
//  OBJCLucene
//
//  Created by Sean Lynch on 4/8/14.
//
//

#import "NSEntityDescription+OCLIncrementalStore.h"
#import "NSString+OCL.h"
#import "NumericUtils.h"
#import "NumberTools.h"
#include "MatchAllDocsQuery.h"
#include <vector>

using namespace lucene::search;
using namespace lucene::document;
using namespace lucene::index;
using namespace std;
using namespace ocl;

@implementation NSEntityDescription (OCLIncrementalStore)

- (Query *)queryForPredicate:(NSPredicate *)predicate indexReader:(IndexReader *)inIndexReader
{
    if([predicate isKindOfClass:[NSCompoundPredicate class]]) {
        return [self queryForCompoundPredicate:(NSCompoundPredicate *)predicate indexReader:inIndexReader];
    } else if([predicate isKindOfClass:[NSComparisonPredicate class]]) {
        return [self queryForComparisonPredicate:(NSComparisonPredicate *)predicate indexReader:inIndexReader];
    }
    return NULL;
}

- (Query *)queryForCompoundPredicate:(NSCompoundPredicate *)predicate indexReader:(IndexReader *)inIndexReader
{
    BooleanQuery *query = _CLNEW BooleanQuery(true);
    [predicate.subpredicates enumerateObjectsUsingBlock:^(NSPredicate *subPredicate, NSUInteger index, BOOL *stop) {
        switch (predicate.compoundPredicateType) {
            case NSNotPredicateType:
                query->add([self queryForPredicate:predicate indexReader:inIndexReader], true, BooleanClause::MUST_NOT);
                break;
                
            case NSAndPredicateType:
                query->add([self queryForPredicate:predicate indexReader:inIndexReader], true, BooleanClause::MUST);
                break;
                
            case NSOrPredicateType:
                query->add([self queryForPredicate:predicate indexReader:inIndexReader], true, BooleanClause::SHOULD);
                break;
                
            default:
                break;
        }
    }];
    return query;
}

- (Query *)queryForComparisonPredicate:(NSComparisonPredicate *)predicate indexReader:(IndexReader *)inIndexReader
{
    NSString *keyPath = nil;
    id value = nil;
    [self parseExpression:predicate.leftExpression intoKeyPath:&keyPath value:&value];
    [self parseExpression:predicate.rightExpression intoKeyPath:&keyPath value:&value];

    const TCHAR *fieldKey = NULL;

    if([keyPath caseInsensitiveCompare:@"self"] == NSOrderedSame) {
        keyPath = @"_id";
    } else if([keyPath hasPrefix:@"self."]) {
        keyPath = [keyPath stringByReplacingOccurrencesOfString:@"self." withString:@""];
    } else if([keyPath hasPrefix:@"SELF."]) {
        keyPath = [keyPath stringByReplacingOccurrencesOfString:@"SELF." withString:@""];
    }

    NSAttributeDescription *attribute = self.attributesByName[keyPath];
    NSRelationshipDescription *relationship = self.relationshipsByName[keyPath];
    const TCHAR *(^parseFieldValue)(id) = ^(id localValue) {
        const TCHAR *result = NULL;
        switch (attribute.attributeType) {
            case NSInteger16AttributeType:
            case NSInteger32AttributeType:
            case NSInteger64AttributeType:
                result = NumberTools::longToString([localValue longLongValue]);
                break;
                
            case NSDateAttributeType:
                localValue = @([localValue timeIntervalSince1970]);
            case NSFloatAttributeType:
            case NSDecimalAttributeType:
            case NSDoubleAttributeType:
                result = NumberTools::longToString(NumericUtils::doubleToSortableLong([localValue doubleValue]));
                break;
                
            case NSStringAttributeType:
                if(predicate.predicateOperatorType == NSEndsWithPredicateOperatorType) {
                    result = [[NSString stringWithFormat:@"*%@", localValue] toTCHAR];
                } else if(predicate.predicateOperatorType == NSContainsPredicateOperatorType) {
                    result = [[NSString stringWithFormat:@"*%@*", localValue] toTCHAR];
                } else {
                    result = [localValue toTCHAR];
                }
                break;

            default:
                break;
        }
        return result;
    };

    const TCHAR *(^parseManagedObjectType)(id) = ^(id localValue) {
        if([localValue isKindOfClass:[NSManagedObject class]]) {
            localValue = [localValue objectID];
        }
        if([localValue isKindOfClass:[NSManagedObjectID class]]) {
            NSManagedObjectID *objectID = localValue;
            return [[(NSIncrementalStore *)objectID.persistentStore referenceObjectForObjectID:objectID] toTCHAR];
        }  else if([localValue isKindOfClass:[NSString class]]) {
            return [localValue toTCHAR];
        } else {
            return (const TCHAR *)NULL;
        }
    };

    vector<Term *> terms;

    fieldKey = [keyPath toTCHAR];
    if([value isKindOfClass:[NSDictionary class]]) {
        value = [value allValues];
    }
    
    if(attribute != nil) {
        if([value conformsToProtocol:@protocol(NSFastEnumeration)]) {
            for(id singleValue in value) {
                Term *term = _CLNEW Term(fieldKey, parseFieldValue(singleValue));
                terms.push_back(term);
            }
        } else {
            Term *term = _CLNEW Term(fieldKey, parseFieldValue(value));
            terms.push_back(term);
        }
    } else if(relationship != nil || [keyPath isEqualToString:@"_id"]) {
        if([value conformsToProtocol:@protocol(NSFastEnumeration)]) {
            for(id singleValue in value) {
                Term *term = _CLNEW Term(fieldKey, parseManagedObjectType(singleValue));
                terms.push_back(term);
            }
        } else {
            Term *term = _CLNEW Term(fieldKey, parseManagedObjectType(value));
            terms.push_back(term);
        }
    }

    if(terms.size() == 0) {
        return NULL;
    }

    Term *term = terms[0];

    Query *query = NULL;

    switch (predicate.predicateOperatorType) {
        case NSLessThanPredicateOperatorType: {
            query = _CLNEW RangeQuery(NULL, term, false);
            break;
        }

        case NSLessThanOrEqualToPredicateOperatorType: {
            query = _CLNEW RangeQuery(NULL, term, true);
            break;
        }

        case NSGreaterThanPredicateOperatorType: {
            query = _CLNEW RangeQuery(term, NULL, false);
            break;
        }

        case NSGreaterThanOrEqualToPredicateOperatorType: {
            query = _CLNEW RangeQuery(term, NULL, true);
            break;
        }

        case NSEqualToPredicateOperatorType: {
            query = _CLNEW TermQuery(term);
            break;
        }

        case NSNotEqualToPredicateOperatorType: {
            BooleanQuery *booleanQuery = _CLNEW BooleanQuery(true);
            TermQuery *termQuery = _CLNEW TermQuery(term);
            booleanQuery->add(_CLNEW MatchAllDocsQuery(), true, BooleanClause::MUST);
            booleanQuery->add(termQuery, true, BooleanClause::MUST_NOT);
            query = booleanQuery;
            break;
        }

        case NSMatchesPredicateOperatorType:
            break;

        case NSLikePredicateOperatorType: {
            query = _CLNEW WildcardQuery(term);
            break;
        }

        case NSBeginsWithPredicateOperatorType: {
            query = _CLNEW PrefixQuery(term);
            break;
        }

        case NSEndsWithPredicateOperatorType: {
            query = _CLNEW WildcardQuery(term);
            break;
        }

        case NSInPredicateOperatorType: {
            BooleanQuery *booleanQuery = _CLNEW BooleanQuery();
            for(Term *localTerm: terms) {
                booleanQuery->add(_CLNEW TermQuery(localTerm), true, BooleanClause::SHOULD);
            }
            query = booleanQuery;
            break;
        }

        case NSCustomSelectorPredicateOperatorType:
            break;

        case NSContainsPredicateOperatorType:
            query = _CLNEW WildcardQuery(term);
            break;

        case NSBetweenPredicateOperatorType:
            query = _CLNEW RangeQuery(terms[0], terms[1], true);
            break;

        default:
            break;
    }
    for(Term *term: terms) {
        _CLDECDELETE(term);
    }
    return query;
}

- (void)parseExpression:(NSExpression *)expression intoKeyPath:(NSString **)inOutKeyPath value:(id*)inOutValue
{
    switch (expression.expressionType) {
        case NSKeyPathExpressionType: {
            [self setPointer:inOutKeyPath withValue:expression.keyPath];
            break;
        }

        case NSConstantValueExpressionType: {
            [self setPointer:inOutValue withValue:expression.constantValue];
            break;
        }

        case NSEvaluatedObjectExpressionType: {
            [self setPointer:inOutKeyPath withValue:@"SELF"];
            break;
        }

        case NSAggregateExpressionType: {
            NSMutableArray *values = [NSMutableArray array];
            for(NSExpression *subExpression in expression.collection) {
                id tmpValue = nil;
                [self parseExpression:subExpression intoKeyPath:inOutKeyPath value:&tmpValue];
                if(tmpValue != nil) {
                    [values addObject:tmpValue];
                }
            }
            [self setPointer:inOutValue withValue:values];
            break;
        }

        default:
            break;
    }
}

- (void)setPointer:(id*)pointer  withValue:(id)value
{
    if(pointer != NULL) {
        *pointer = value;
    }
}

@end
