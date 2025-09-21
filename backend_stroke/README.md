# Predicción de Accidentes Cerebrovasculares (Stroke Prediction)

Este proyecto busca predecir la probabilidad de que un paciente sufra un accidente cerebrovascular, usando variables clínicas y demográficas. Para ello se entrenó un modelo optimizado con técnicas de balanceo y un pipeline profesional.

## 🧠 Objetivo
Construir un modelo de clasificación binaria para detectar casos potenciales de stroke en pacientes, con alta sensibilidad, evitando que pase desapercibido un caso real.

## 📊 Dataset
- Fuente: Kaggle
- Nombre: [Stroke Prediction Dataset](https://www.kaggle.com/datasets/fedesoriano/stroke-prediction-dataset)
- Registros: 5,110 pacientes

## ⚙️ Preprocesamiento y Modelado
- Imputación de nulos
- Escalado de variables numéricas
- Codificación one-hot de categóricas
- SMOTE para balanceo de clases
- Modelo final: XGBoost optimizado con RandomizedSearchCV

## 📈 Resultados
- Recall clase positiva: 0.83
- ROC-AUC: 0.72
- Accuracy: 0.47

## ✅ Conclusiones
- Modelo centrado en sensibilidad clínica
- Pipeline modular, escalable y exportable

## 💾 Exportación
```python
import joblib
joblib.dump(final_pipeline, 'pipeline_modelo_stroke.pkl')
```

## 👨‍💻 Autor
**Wladimir Cabascango**  
_Data Scientist | ML Engineer - Quito, Ecuador_