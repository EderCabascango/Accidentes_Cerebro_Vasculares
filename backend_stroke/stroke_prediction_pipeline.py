# -*- coding: utf-8 -*-
"""
Pipeline profesional para predicción de accidentes cerebrovasculares (stroke)
Incluye:
- Preprocesamiento completo
- Balanceo con SMOTE
- Entrenamiento con XGBoost optimizado
- Evaluación final
- Guardado del pipeline
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from imblearn.pipeline import Pipeline as ImbPipeline
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from imblearn.over_sampling import SMOTE
from xgboost import XGBClassifier
from sklearn.metrics import classification_report, confusion_matrix, roc_auc_score, accuracy_score, f1_score, recall_score
import joblib

# === CARGA DE DATOS ===
df = pd.read_csv('healthcare-dataset-stroke-data.csv')

# === LIMPIEZA Y ENRIQUECIMIENTO ===
df['bmi'].fillna(df['bmi'].mean(), inplace=True)
df['age'] = df['age'].astype(int)
df['hypertension'] = df['hypertension'].replace({0: 'No', 1: 'Yes'})
df['heart_disease'] = df['heart_disease'].replace({0: 'No', 1: 'Yes'})

# Ingeniería de variables

# 1. Edad agrupada
df['age_group'] = pd.cut(df['age'], bins=[0, 18, 40, 60, 120],
                         labels=['Niño', 'Joven', 'Adulto', 'Mayor'])

# 2. IMC agrupado
df['bmi_group'] = pd.cut(df['bmi'], bins=[0, 18.5, 24.9, 29.9, 100],
                         labels=['Bajo', 'Normal', 'Sobrepeso', 'Obeso'])

# 3. Interacción hipertensión + cardiopatía
df['hiper_cardio'] = df['hypertension'].astype(str) + "_" + df['heart_disease'].astype(str)

# Eliminamos columna ID y reorganizamos
df = df.drop(columns=['id'])

# === SEPARACIÓN DE FEATURES Y TARGET ===
X = df.drop(columns='stroke')
y = df['stroke'].replace({'Yes': 1, 'No': 0})

# === DIVISIÓN ENTRENAMIENTO / TEST ===
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.3, stratify=y, random_state=42
)

# === COLUMNAS POR TIPO ===
categorical_cols = X.select_dtypes(include='object').columns.tolist()
numerical_cols = X.select_dtypes(include=['float64', 'int64']).columns.tolist()

# === PIPELINES DE PREPROCESAMIENTO ===
numerical_pipeline = Pipeline(steps=[
    ('imputer', SimpleImputer(strategy='mean')),
    ('scaler', StandardScaler())
])

categorical_pipeline = Pipeline(steps=[
    ('imputer', SimpleImputer(strategy='most_frequent')),
    ('encoder', OneHotEncoder(handle_unknown='ignore', sparse_output=False))
])

preprocessor = ColumnTransformer(transformers=[
    ('num', numerical_pipeline, numerical_cols),
    ('cat', categorical_pipeline, categorical_cols)
])

# === MODELO OPTIMIZADO ===
xgb_model = XGBClassifier(
    n_estimators=200,
    learning_rate=0.1,
    max_depth=5,
    subsample=0.8,
    colsample_bytree=0.8,
    random_state=42,
    use_label_encoder=False,
    eval_metric='logloss'
)

# === PIPELINE FINAL COMPLETO ===
final_pipeline = ImbPipeline(steps=[
    ('preprocessing', preprocessor),
    ('smote', SMOTE(random_state=42)),
    ('classifier', xgb_model)
])

# === ENTRENAMIENTO ===
final_pipeline.fit(X_train, y_train)

# === EVALUACIÓN ===
y_pred = final_pipeline.predict(X_test)
y_proba = final_pipeline.predict_proba(X_test)[:, 1]

print("\n--- EVALUACIÓN FINAL ---")
print("ROC-AUC:", roc_auc_score(y_test, y_proba))
print("Recall:", recall_score(y_test, y_pred))
print("F1-score:", f1_score(y_test, y_pred))
print("Accuracy:", accuracy_score(y_test, y_pred))
print("\nConfusion Matrix:\n", confusion_matrix(y_test, y_pred))
print("\nClassification Report:\n", classification_report(y_test, y_pred))

# === GUARDADO DEL PIPELINE ENTRENADO ===
joblib.dump(final_pipeline, 'pipeline_modelo_stroke.pkl')
