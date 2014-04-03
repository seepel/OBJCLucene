//
//  BlockHitCollector.cpp
//  OBJCLucene
//
//  Created by Sean Lynch on 4/2/14.
//
//

#include "BlockHitCollector.h"

using namespace std;
using namespace lucene::index;
using namespace lucene::document;
using namespace ocl;

BlockHitCollector::BlockHitCollector(FieldSelectorBlock selectorBlock, HitCollectorBlock collectorBlock, IndexReader *indexReader) :
_fieldSelector(selectorBlock)
{
    _block = collectorBlock;
    _indexReader = indexReader;
}

void BlockHitCollector::collect(const int32_t doc, const float_t score)
{
    Document document;
    _indexReader->document(doc, document, &_fieldSelector);
    _block(document, score);
}