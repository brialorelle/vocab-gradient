 
# 
# followed instructions using https://github.com/jina-ai/clip-as-service/tree/main/server

# before starting, run
# python3 -m clip_server
# python3

from clip_client import Client
c = Client('grpc://0.0.0.0:51000')
import pandas as pd
import numpy as np
# has category items


# from things
items = pd.read_csv('things_concepts.tsv', sep='\t')
all_items = list(items['Word'])
all_items =  all_items

# wow so fast
item_embeddings = c.encode(all_items)
embeddings_items = np.size(item_embeddings,0)
embeddings_vector_length= np.size(item_embeddings,0)


# get correlations and save
item_correlations = np.corrcoef(item_embeddings)
item_correlations_df = pd.DataFrame(item_correlations)
item_correlations_df.columns = all_items
item_correlations_df_transposed = item_correlations_df.transpose()
item_correlations_df_transposed.columns = all_items
item_correlations_df_transposed.to_csv('things_test_all_item_embeddings.csv')


