print('Loading libraries...')
import numpy as np
import pandas as pd
import lightgbm as lgb
import gc
import os
import random

print('Setting options...')
random.seed(2017)
cwd = os.getcwd()
os.chdir("/home/jason/Desktop/zillow/code")
cwd

print('Loading data ...')

#train = pd.read_csv('../data/train_2016.csv')
#prop = pd.read_csv('../data/properties_2016.csv')
#prop = pd.read_csv('file:///home/jason/Downloads/props_r_export_for_python.csv')
train = pd.read_csv('../data/train_py.csv')
prop = pd.read_csv('../data/props_r_export_for_python.csv')

print("ETL...")
for c, dtype in zip(prop.columns, prop.dtypes):
    if dtype == np.float64:
        prop[c] = prop[c].astype(np.float32)

df_train = train.merge(prop, how='left', on='parcelid')

months={10,11,12}
x_valid = df_train.loc[df_train['month'].isin(months)]
y_valid= x_valid['logerror'].values
drops=['parcelid', 'logerror', 'transactiondate',
                         'propertyzoningdesc', 'taxdelinquencyyear','poolcnt','decktypeid',
                         'pooltypeid10', 'month','flag_3ormore_fireplace',
                         'flag_3ormore_garage','basementsqft',
                         'yearbuilt','yardbuildingsqft26',
                        'yardbuildingsqft17','finishedsquarefeet6',
                         'poolsizesum'] #,'flag_co_code_high'
x_valid = x_valid.drop(drops, axis=1)
x_train = df_train.drop(drops, axis=1)
y_train = df_train['logerror'].values
print(x_train.shape, y_train.shape)
print(x_valid.shape, y_valid.shape)

train_columns = x_train.columns
cf=['flag_co_code_low',
    'flag_co_code_high',
    'propertycountylandusecode',
    'buildingclasstypeid',
    "airconditioningtypeid",
    "architecturalstyletypeid",
    "buildingclasstypeid",
    "buildingqualitytypeid",
    "heatingorsystemtypeid",
    "propertylandusetypeid",
    "typeconstructiontypeid",
    "pooltypeid2",
    "pooltypeid7",
    "storytypeid",
    "fips6037",
    "fips6059",
    "fips6111"
    ]

for c in x_train.dtypes[x_train.dtypes == object].index.values:
    x_train[c] = (x_train[c] == True)

for c in x_valid.dtypes[x_valid.dtypes == object].index.values:
    x_valid[c] = (x_valid[c] == True)

x_train = x_train.values.astype(np.float32, copy=False)
x_valid = x_valid.values.astype(np.float32, copy=False)

num_train, num_feature = x_train.shape
feature_name = ['feature_' + str(col) for col in range(num_feature)]

#for x in range(num_feature):
#    print('{0} th feature name is:'.format(x))
#    print(train_columns[x].format(x)) # % (x)) #

d_train = lgb.Dataset(x_train, label=y_train,feature_name=train_columns)#,feature_name=train_columns,categorical_feature=[0])
d_valid = lgb.Dataset(x_valid, label=y_valid)#,reference=d_train,feature_name=train_columns,categorical_feature=cf)

params = {}
params['max_bin'] = 10
params['learning_rate'] = 0.0021 # shrinkage_rate
params['boosting_type'] = 'gbdt'
params['objective'] = 'regression'
params['metric'] = 'l2'          # or 'mae'
params['sub_feature'] = 0.5      # feature_fraction
params['bagging_fraction'] = 0.85 # sub_row
params['bagging_freq'] = 40
params['num_leaves'] = 60        # num_leaf
params['min_data'] = 500         # min_data_in_leaf
params['min_hessian'] = 0.05     # min_sum_hessian_in_leaf

# Train Model
watchlist = [d_valid]
num_round = 1000
clf = lgb.train(params, d_train, num_round, valid_sets=watchlist,
                feature_name=feature_name,
                categorical_feature=[0,1,3,4,5,17,18,22,23,24,25,27,28,29,30,32,33,34,37,40,43,44,45,46,47,48,49,50,51,52,54,55,57,58])#watchlist)#, feature_name=train_columns,categorical_feature=cf,early_stopping_rounds=20)
#0.0266698  .025901

vi=clf.feature_importance()
vi=pd.DataFrame(vi)
cn=pd.DataFrame(train_columns)
feat_imp = pd.concat([vi, cn], axis=1)
feat_imp.columns = ['importance','name']
print(feat_imp)

del df_train; gc.collect()

#result = df.sort(['A', 'B'], ascending=[1, 0])
#del d_train, d_valid; gc.collect()
#del x_train, x_valid; gc.collect()

print("Preparing for the predictions...")
sample = pd.read_csv('../data/sample_submission.csv')
sample['parcelid'] = sample['ParcelId']
df_test = sample.merge(prop, on='parcelid', how='left')

#del sample, prop; gc.collect()
x_test = df_test[train_columns]
#del df_test; gc.collect()
for c in x_test.dtypes[x_test.dtypes == object].index.values:
    x_test[c] = (x_test[c] == True)
x_test = x_test.values.astype(np.float32, copy=False)

print("Starting the predictions...")
# num_threads > 1 will predict very slow in kernal
clf.reset_parameter({"num_threads":1})
p_test = clf.predict(x_test,num_iteration=clf.best_iteration)

#del x_test; gc.collect()

print("Starting to write out the results ...")
sub = pd.read_csv('../data/sample_submission.csv')
for c in sub.columns[sub.columns != 'ParcelId']:
    sub[c] = p_test

sub.to_csv('../data/my_py_lgb.csv', index=False, float_format='%.4f')
