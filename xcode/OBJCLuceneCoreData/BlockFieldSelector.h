//
//  BlockFieldSelector.h
//  OBJCLucene
//
//  Created by Sean Lynch on 4/2/14.
//
//

#ifndef __OBJCLucene__BlockFieldSelector__
#define __OBJCLucene__BlockFieldSelector__

#include "CLucene.h"
#include "FieldSelector.h"


namespace ocl {
    typedef lucene::document::FieldSelector::FieldSelectorResult (^FieldSelectorBlock)(const TCHAR *fieldName);
    class BlockFieldSelector : public lucene::document::FieldSelector {
    public:
        BlockFieldSelector(FieldSelectorBlock block);
        lucene::document::FieldSelector::FieldSelectorResult accept(const TCHAR *fieldName) const;
    private:
        FieldSelectorBlock _block;
    };
}

#endif /* defined(__OBJCLucene__BlockFieldSelector__) */
