from allauth.exceptions import ImmediateHttpResponse
from allauth.socialaccount.adapter import DefaultSocialAccountAdapter
from django.contrib.auth import get_user_model
from django.core.exceptions import PermissionDenied

User = get_user_model()

class CustomSocialAccountAdapter(DefaultSocialAccountAdapter):
    def pre_social_login(self, request, sociallogin):
        # Check if user with same email exists but no social account
        email = sociallogin.user.email
        if email:
            try:
                existing_user = User.objects.get(email=email)
                # If user exists but no social account connected, prevent login
                if not sociallogin.is_existing:
                    # Check if this user has any social account
                    if not existing_user.socialaccount_set.filter(provider=sociallogin.account.provider).exists():
                        # Prevent auto-linking
                        raise ImmediateHttpResponse(
                            PermissionDenied(
                                "An account with this email already exists. Please login with password or link your Google account."
                            )
                        )
            except User.DoesNotExist:
                pass
        return super().pre_social_login(request, sociallogin)
