# -*- coding: utf-8 -*-
"""
Created on Fri Mar 20 23:31:57 2020

@author: SmritiMalhotra
"""

"""
Create the Dash App. 
"""
#%%
import pandas as pd
from pandas.api.types import CategoricalDtype
#import numpy as np
import dash
from dash.dependencies import Input, Output
import dash_core_components as dcc
import dash_html_components as html
from pyproj import Proj, transform
import matplotlib.pyplot as plt
import datashader as ds
import datashader.transfer_functions as tf
import datashader.glyphs
from datashader import reductions
from datashader.core import bypixel
from datashader.utils import lnglat_to_meters as webm, export_image
from datashader.colors import colormap_select, Greys9, viridis, inferno
from functools import partial

#%%

"""
Download database from the NYC City .

Store data in a data frame named trees.
"""
#%%
url = 'https://data.cityofnewyork.us/resource/nwxe-4ae8.json?$limit=685000'
trees = pd.read_json(url)
trees.head(10)
#%%

"""
Data Cleaning :  change health codes into a usable form. 
Assign Fair to missing values 
"""
#%%
#print(trees.shape)
cat_type = CategoricalDtype(categories=["Poor", "Fair", "Good"], ordered = True)
trees['health'] = trees['health'].astype(cat_type)
print(trees['health'].describe())
print(trees['health'].cat.codes[:10])
trees['health'].isna().sum()
trees['health'] = trees['health'].fillna('Fair')
trees['health'] = trees['health'].cat.codes
print(trees['health'][:10])
print(trees['health'].describe())
#%%

#%%
trees['steward'] = trees['steward'].fillna('None')
#%%

"""
Plot histogram for comparison to the one that will appear in the 
Dash App
"""
#%%
trees['health'].hist()
plt.show()
#%%

"""
Used the code from that project to make datashader images of the trees location
and health to embed into the Dash App.

"""

#%%
wgs84 = Proj("+proj=longlat +ellps=GRS80 +datum=NAD83 +no_defs")
nyli = Proj("+proj=lcc +lat_1=40.66666666666666 +lat_2=41.03333333333333 +lat_0=40.16666666666666 +lon_0=-74 +x_0=300000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs")
trees['x_sp'] = 0.3048*trees['x_sp']
trees['y_sp'] = 0.3048*trees['y_sp']
trees['lon'], trees['lat'] = transform(nyli, wgs84, trees['x_sp'].values, trees['y_sp'].values)

trees = trees[(trees['lon'] < -60) & (trees['lon'] > -100) & (trees['lat'] < 60) & (trees['lat'] > 20)]

#Also using project 2 code to get a map locating the trees.
#Defining some helper functions for DataShader
background = "black"
export = partial(export_image, background = background, export_path="export")
cm = partial(colormap_select, reverse=(background!="black"))

NewYorkCity   = (( -74.29,  -73.69), (40.49, 40.92))
cvs = ds.Canvas(700, 700, *NewYorkCity)
agg = cvs.points(trees, 'lon', 'lat')
view = tf.shade(agg, cmap = cm(viridis), how='log')
export(tf.spread(view, px=2), 'trees')
agg = cvs.points(trees, 'lon', 'lat', ds.mean('health'))
view = tf.shade(agg, cmap = cm(viridis), how='eq_hist')
export(tf.spread(view, px=2), 'trees_health')
#%%

"""
Code block below is the actual Dash App. It displays the images with the 
user inputs defined by Radio bottons. It then subsets the dataframe and 
displays the appropreiate histogram.
"""

#%%
# https://www.youtube.com/watch?v=wv2MXJIdKRY
#https://dash.plot.ly/getting-started-part-2
app = dash.Dash()

app.layout = html.Div(children=[
    html.H1(children = 'New York City Street Tree Health'),
    html.P('Graphics show health of trees along city streets in NYC'),
    html.P('First select a Borough: '),
    dcc.RadioItems(
        id='dropdown-a',
        options=[{'label': i, 'value': i} for i in ['Bronx', 'Brooklyn', 'Manhattan', 'Queens', 'Staten Island']],
        value='Queens'
    ),
    html.Div(id='output-a'),
    html.P("0 = Poor Health; 1 = Fair Health, 2 = Good Health"),
    dcc.RadioItems(
        id='dropdown-b',
        options=[{'label': i, 'value': i} for i in trees['steward'].unique()],
        value='None'
    ),
    html.Div(id='output-b'),
    html.P("0 = Poor Health; 1 = Fair Health, 2 = Good Health")
    ])

@app.callback(
        Output(component_id='output-a', component_property='children'),
        [Input(component_id='dropdown-a', component_property='value')]
        )

def boro_graph(input_data):
    df = trees[trees.boroname == input_data]
    
    return dcc.Graph(
            id='Health by Borough',
            figure={
                    'data':[
              {'x':df['health'], 'type': 'histogram','name': 'Health by Borough'}
          ],
          'layout':{
              'title':"Health by Borough"
                  }
          }
              )

@app.callback(
        Output(component_id='output-b', component_property='children'),
        [Input(component_id='dropdown-b', component_property='value')]
        )

def steward_graph(input_data):
    df = trees[trees.steward == input_data]
    
    return dcc.Graph(
            id='Health by Steward',
            figure={
                    'data':[
              {'x':df['health'], 'type': 'histogram','name': 'Health by Stewardship'}
          ],
          'layout':{
              'title':"Health by Stewardship"
                  }
          }
              )


if __name__ == '__main__':
    app.run_server(debug=False)
#%%