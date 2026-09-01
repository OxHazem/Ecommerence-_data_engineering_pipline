# # # Data_generator/exchange_rate/service.py

# # from datetime import date

# # from .api_client import ExchangeRateAPIClient
# # from .config import BASE_CURRENCY, SUPPORTED_CURRENCIES


# # class ExchangeRateService:
# #     """
# #     Provides exchange rates required by the ecommerce pipeline.
# #     """

# #     def __init__(self, client=None):
# #         self.client = client or ExchangeRateAPIClient()

# #     def get_rate(
# #         self,
# #         from_currency,
# #         to_currency=BASE_CURRENCY,
# #         rate_date=None
# #     ):
# #         """
# #         Get an exchange rate between two currencies.
# #         """

# #         from_currency = from_currency.upper()
# #         to_currency = to_currency.upper()

# #         self._validate_currency(from_currency)
# #         self._validate_currency(to_currency)

# #         if from_currency == to_currency:
# #             return {
# #                 "date": (
# #                     rate_date.isoformat()
# #                     if isinstance(rate_date, date)
# #                     else rate_date
# #                 ),
# #                 "base": from_currency,
# #                 "quote": to_currency,
# #                 "rate": 1
# #             }

# #         return self.client.get_rate(
# #             from_currency=from_currency,
# #             to_currency=to_currency,
# #             rate_date=rate_date
# #         )

# #     @staticmethod
# #     def _validate_currency(currency):
# #         """
# #         Validate that a currency is supported.
# #         """

# #         if currency not in SUPPORTED_CURRENCIES:
# #             raise ValueError(
# #                 f"Unsupported currency: {currency}. "
# #                 f"Supported currencies: "
# #                 f"{SUPPORTED_CURRENCIES}"
# #             )


# # Data_generator/exchange_rate/service.py

# from datetime import date

# from .api_client import ExchangeRateAPIClient
# from .config import BASE_CURRENCY, SUPPORTED_CURRENCIES


# class ExchangeRateService:
#     """
#     Provides exchange rates required by the ecommerce pipeline.
#     """

#     def __init__(self, client=None):
#         self.client = client or ExchangeRateAPIClient()

#     def get_rate(
#         self,
#         from_currency,
#         to_currency=BASE_CURRENCY,
#         rate_date=None
#     ):
#         """
#         Get an exchange rate between two currencies.
#         """

#         from_currency = from_currency.upper()
#         to_currency = to_currency.upper()

#         self._validate_currency(from_currency)
#         self._validate_currency(to_currency)

#         if from_currency == to_currency:

#             return {
#                 "date": (
#                     rate_date.isoformat()
#                     if isinstance(rate_date, date)
#                     else rate_date
#                 ),
#                 "base": from_currency,
#                 "quote": to_currency,
#                 "rate": 1
#             }

#         return self.client.get_rate(
#             from_currency=from_currency,
#             to_currency=to_currency,
#             rate_date=rate_date
#         )

#     def get_historical_rates(
#         self,
#         from_currency,
#         to_currency=BASE_CURRENCY,
#         start_date=None,
#         end_date=None
#     ):
#         """
#         Get historical exchange rates over a date range.
#         """

#         from_currency = from_currency.upper()
#         to_currency = to_currency.upper()

#         self._validate_currency(from_currency)
#         self._validate_currency(to_currency)

#         if start_date is None or end_date is None:
#             raise ValueError(
#                 "start_date and end_date are required."
#             )

#         if from_currency == to_currency:

#             return [
#                 {
#                     "date": current_date.isoformat(),
#                     "base": from_currency,
#                     "quote": to_currency,
#                     "rate": 1
#                 }
#                 for current_date in self._date_range(
#                     start_date,
#                     end_date
#                 )
#             ]

#         return self.client.get_historical_rates(
#             from_currency=from_currency,
#             to_currency=to_currency,
#             start_date=start_date,
#             end_date=end_date
#         )

#     @staticmethod
#     def _date_range(start_date, end_date):

#         from datetime import timedelta

#         current_date = start_date

#         while current_date <= end_date:
#             yield current_date
#             current_date += timedelta(days=1)

#     @staticmethod
#     def _validate_currency(currency):

#         if currency not in SUPPORTED_CURRENCIES:

#             raise ValueError(
#                 f"Unsupported currency: {currency}. "
#                 f"Supported currencies: "
#                 f"{SUPPORTED_CURRENCIES}"
#             )

# Data_generator/exchange_rate/service.py

from datetime import date, timedelta

from .api_client import ExchangeRateAPIClient
from .config import BASE_CURRENCY, SUPPORTED_CURRENCIES


class ExchangeRateService:
    """
    Provides exchange rates required by the ecommerce pipeline.
    """

    def __init__(self, client=None):
        self.client = client or ExchangeRateAPIClient()

    # ========================================================
    # SINGLE DATE
    # ========================================================

    def get_rate(
        self,
        from_currency,
        to_currency=BASE_CURRENCY,
        rate_date=None
    ):
        """
        Get an exchange rate between two currencies
        for one specific date.
        """

        from_currency = from_currency.upper()
        to_currency = to_currency.upper()

        self._validate_currency(from_currency)
        self._validate_currency(to_currency)

        # ----------------------------------------------------
        # Same currency
        # ----------------------------------------------------

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

        # ----------------------------------------------------
        # API request
        # ----------------------------------------------------

        return self.client.get_rate(
            from_currency=from_currency,
            to_currency=to_currency,
            rate_date=rate_date
        )

    # ========================================================
    # HISTORICAL DATE RANGE
    # ========================================================

    def get_historical_rates(
        self,
        from_currency,
        to_currency=BASE_CURRENCY,
        start_date=None,
        end_date=None
    ):
        """
        Get historical exchange rates over a date range.
        """

        from_currency = from_currency.upper()
        to_currency = to_currency.upper()

        self._validate_currency(from_currency)
        self._validate_currency(to_currency)

        # ----------------------------------------------------
        # Validate dates
        # ----------------------------------------------------

        if start_date is None or end_date is None:
            raise ValueError(
                "start_date and end_date are required."
            )

        if isinstance(start_date, str):
            start_date = date.fromisoformat(start_date)

        if isinstance(end_date, str):
            end_date = date.fromisoformat(end_date)

        if start_date > end_date:
            raise ValueError(
                "start_date cannot be after end_date."
            )

        # ----------------------------------------------------
        # Same currency
        # EGP -> EGP = 1
        # ----------------------------------------------------

        if from_currency == to_currency:

            return [
                {
                    "date": current_date.isoformat(),
                    "base": from_currency,
                    "quote": to_currency,
                    "rate": 1
                }
                for current_date in self._date_range(
                    start_date,
                    end_date
                )
            ]

        # ----------------------------------------------------
        # Historical API request
        # ----------------------------------------------------

        return self.client.get_historical_rates(
            from_currency=from_currency,
            to_currency=to_currency,
            start_date=start_date,
            end_date=end_date
        )

    # ========================================================
    # DATE RANGE HELPER
    # ========================================================

    @staticmethod
    def _date_range(start_date, end_date):
        """
        Generate every calendar date between start and end.
        """

        current_date = start_date

        while current_date <= end_date:

            yield current_date

            current_date += timedelta(days=1)

    # ========================================================
    # CURRENCY VALIDATION
    # ========================================================

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