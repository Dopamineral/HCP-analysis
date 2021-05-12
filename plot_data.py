# -*- coding: utf-8 -*-
"""
Created on Wed May 12 14:54:56 2021

@author: Robert
"""

import pandas as pd
import os
import seaborn as sns
import matplotlib.pyplot as plt

# Loading data
os.chdir("E:/Neuroradiology/scripts")
data_left = pd.read_csv("data_lefthemi.csv")
data_right = pd.read_csv("data_righthemi.csv")
data_bilateral = pd.read_csv("data_bilateral.csv")
master_data = pd.read_csv("masterdata.csv")

master_tidy = pd.melt(master_data,'hemisphere',var_name = "metric")

master_ready = pd.read_csv("masterdata_ready_pretty3.csv")

sns.set_theme(style="whitegrid")
# Initialize the figure
f, ax = plt.subplots(figsize=(10, 10), dpi=80)
sns.despine(bottom=True, left=True)

# Show each observation with a scatterplot
sns.stripplot(x="value", y="Language Network - Metric", hue="hemisphere",
              data=master_ready, dodge=True, alpha=.25, zorder=1)

# Show the conditional means
sns.pointplot(x="value", y="Language Network - Metric", hue="hemisphere",
              data=master_ready, dodge=.532, join=False, palette="dark",
              markers="d", scale=.75, ci=None)

# Improve the legend 
handles, labels = ax.get_legend_handles_labels()
ax.legend(handles[3:], labels[3:], title="Hemisphere",
          handletextpad=0, columnspacing=1,
          loc="lower right", ncol=3, frameon=True)


