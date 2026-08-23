# Data_generator/exchange_rate/service.py

from datetime import date

from .api_client import ExchangeRateAPIClient
from .config import BASE_CURRENCY, SUPPORTED_CURRENCIES


class ExchangeRateService:
    """
    Provides exchange rates required by the ecommerce pipeline.
    """

    def __init__(self, client=None):
        self.client = client or ExchangeRateAPIClient()

    def get_rate(
        self,
        from_currency,
        to_currency=BASE_CURRENCY,
        rate_date=None
    ):
        """
        Get an exchange rate between two currencies.
        """

        from_currency = from_currency.upper()
        to_currency = to_currency.upper()

        self._validate_currency(from_currency)
        self._validate_currency(to_currency)

        if from_currency == to_currency:
            return {
                "date": (
                    rate_date.isoformat()
                    if isinstance(rate_date, date)
                    else rate_date
                ),
                "base": from_currency,
                "quote": to_currency,
                "rate": 1
            }

        return self.client.get_rate(
            from_currency=from_currency,
            to_currency=to_currency,
            rate_date=rate_date
        )

    @staticmethod
    def _validate_currency(currency):
        """
        Validate that a currency is supported.
        """

        if currency not in SUPPORTED_CURRENCIES:
            raise ValueError(
                f"Unsupported currency: {currency}. "
                f"Supported currencies: "
                f"{SUPPORTED_CURRENCIES}"
            )