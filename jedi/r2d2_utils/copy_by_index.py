#!/usr/bin/env python3
from r2d2 import R2D2Data

index_to_do = '283015'
item = 'feedback'


R2D2Data.copy_by_index(
    item=item,
    index=index_to_do,
    source_data_store='r2d2-experiments-ssec',
    target_data_store='r2d2-experiments-nwsc',
)
