# XGB-PREAPPROVEDAPP

This notebook builds a model to predict if a client will get a personal loan approved.  
It uses a public dataset from Kaggle (“bank loan modelling”) and applies a few steps of preprocessing, sampling, and model training with XGBoost.

## 1. Dataset
The data comes directly from
[Kaggle bank-loan-modelling](https://www.kaggle.com/datasets/itsmesunil/bank-loan-modelling)

After downloading, the notebook keeps one random sample of 50 rows as a small “new applications” test set (`aliquota_test.csv`) and uses the rest for training.

## 2. Target variable
The column "Personal Loan" is the target.  
All other columns are used as features.

## 3. Model
The main model is an **XGBoostClassifier**, trained to classify loan approval decisions.  
To deal with class imbalance, the notebook uses **SMOTE**.  
The training process uses a simple split between training and testing sets.

The notebook reports the following metrics:
- Accuracy  
- Precision  
- Recall  
- F1-score  

Each metric helps check how the model performs with imbalanced data.

## 4. Dependencies
These are the main libraries used:
- pandas for data manipulation  
- matplotlib and seaborn for visualizations and correlation heatmap  
- scikit-learn for metrics, train/test split  
- xgboost for model training  
- imbalanced-learn for SMOTE  
- requests, zipfile and io  to download and extract the dataset  

Install them with:

"pip install pandas matplotlib seaborn scikit-learn xgboost imbalanced-learn requests"

## 5. Notes

- The dataset is clean enough to work directly after loading, no major preprocessing is required.

- The heatmap is generated only to visualize correlations, not as part of model training.

- The “aliquota” sample simulates new incoming applications to test the model later.

## 6. Further info
[You tube video](https://youtu.be/Vo8G3O53-10)