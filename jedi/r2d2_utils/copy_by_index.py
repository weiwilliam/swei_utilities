#!/usr/bin/env python3
from r2d2 import R2D2Data

index_to_do = '73744'


R2D2Data.copy_by_index(
    item='observation',
    index=index_to_do,
    source_data_store='r2d2-experiments-msu',
    target_data_store='r2d2-experiments-s4',
)
