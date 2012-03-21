#import "NDTrie.h"

@interface LocationAutocompletePlugin : CDVPlugin {
 @private
  NDMutableTrie* trie_;
}

@property (nonatomic, retain) NDMutableTrie* trie;

@end
