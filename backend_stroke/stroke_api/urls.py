from django.urls import path
from .views import predict_stroke

urlpatterns = [
    path('predict/', predict_stroke),
]
