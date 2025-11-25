from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from rest_framework.filters import SearchFilter, OrderingFilter
from django_filters.rest_framework import DjangoFilterBackend
from billing.models import DiscountCode
from .serializers import StaffDiscountCodeSerializer
from .filters import DiscountCodeFilter
from common.utils.mixins import FieldFilterOverviewMixin

class StaffDiscountCodeViewSet(FieldFilterOverviewMixin, viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated, IsAdminUser]
    serializer_class = StaffDiscountCodeSerializer
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_class = DiscountCodeFilter
    search_fields = ['code', 'description']
    ordering_fields = ['created_at', 'expiration_date', 'percent', 'current_usage']
    lookup_field = 'id'
    def get_queryset(self):
        return DiscountCode.objects.all()