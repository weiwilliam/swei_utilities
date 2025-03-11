#!/usr/bin/env python3
from r2d2 import R2D2Index

item = 'observation_type'
name = 'tempo_no2_tropo'
#item = 'experiment'

user='weiwilliam1987'

search_results = R2D2Index.search(
    item=item,
    name=name,
)
print(search_results)
