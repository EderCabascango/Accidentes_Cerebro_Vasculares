import joblib
import pandas as pd
from rest_framework.decorators import api_view
from rest_framework.response import Response

# Carga del modelo entrenado con Pipeline
model = joblib.load('pipeline_modelo_stroke.pkl')

@api_view(['GET', 'POST'])
def predict_stroke(request):
    if request.method == 'GET':
        return Response({"mensaje": "Usa POST para enviar los datos del paciente."})
    
    # POST
    try:
        data = request.data
        input_data = pd.DataFrame([{
            'gender': data['gender'],
            'age': data['age'],
            'hypertension': data['hypertension'],
            'heart_disease': data['heart_disease'],
            'ever_married': data['ever_married'],
            'work_type': data['work_type'],
            'Residence_type': data['Residence_type'],
            'avg_glucose_level': data['avg_glucose_level'],
            'bmi': data['bmi'],
            'smoking_status': data['smoking_status']
        }])

        input_data['hiper_cardio'] = input_data['hypertension'].astype(str) + "_" + input_data['heart_disease'].astype(str)

        prediction = model.predict(input_data)[0]
        return Response({'stroke_prediction': int(prediction)})
    except Exception as e:
        return Response({'error': str(e)}, status=400)
