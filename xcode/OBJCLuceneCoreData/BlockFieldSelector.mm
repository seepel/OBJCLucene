//
//  BlockFieldSelector.cpp
//  OBJCLucene
//
//  Created by Sean Lynch on 4/2/14.
//
//

#include "BlockFieldSelector.h"

using namespace ocl;
using namespace std;
using namespace lucene::document;

BlockFieldSelector::BlockFieldSelector(FieldSelectorBlock block)
{
    _block = block;
}

FieldSelector::FieldSelectorResult BlockFieldSelector::accept(const TCHAR *fieldName) const
{
    return _block(fieldName);
}