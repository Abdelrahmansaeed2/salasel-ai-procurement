from datetime import UTC, datetime
from decimal import Decimal

from sqlalchemy import DateTime, Float, ForeignKey, Identity, Integer, Numeric, String, Text
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from sqlalchemy.types import UserDefinedType


class Geography(UserDefinedType):
    cache_ok = True

    def get_col_spec(self, **kw):
        return "GEOGRAPHY"


class Base(DeclarativeBase):
    pass


class SupplierProfile(Base):
    """AI-service test scaffold mirroring Salasel.Domain.Entities.SupplierProfile."""

    __tablename__ = "SupplierProfiles"

    supplier_id: Mapped[int] = mapped_column(
        "SupplierID",
        Integer,
        Identity(start=1),
        primary_key=True,
    )
    company_name: Mapped[str] = mapped_column("CompanyName", String(200), nullable=False)
    reliability_score: Mapped[Decimal] = mapped_column(
        "ReliabilityScore",
        Numeric(5, 2),
        nullable=False,
        default=Decimal("0.00"),
    )
    payment_terms: Mapped[str] = mapped_column("PaymentTerms", String(100), nullable=False, default="")
    is_active_for_routing: Mapped[bool] = mapped_column("IsActiveForRouting", nullable=False, default=True)
    latitude: Mapped[float | None] = mapped_column("Latitude", Float, nullable=True)
    longitude: Mapped[float | None] = mapped_column("Longitude", Float, nullable=True)
    location = mapped_column("Location", Geography, nullable=True)

    catalogs: Mapped[list["SupplierCatalog"]] = relationship(
        back_populates="supplier",
        cascade="all, delete-orphan",
    )
    quality_score: Mapped["SupplierQualityScore | None"] = relationship(
        back_populates="supplier",
        cascade="all, delete-orphan",
        uselist=False,
    )


class SupplierCatalog(Base):
    """AI-service test scaffold mirroring Salasel.Domain.Entities.SupplierCatalog."""

    __tablename__ = "SupplierCatalogs"

    catalog_id: Mapped[int] = mapped_column(
        "CatalogID",
        Integer,
        Identity(start=1),
        primary_key=True,
    )
    supplier_id: Mapped[int] = mapped_column(
        "SupplierID",
        ForeignKey("SupplierProfiles.SupplierID"),
        nullable=False,
        index=True,
    )
    sku: Mapped[str] = mapped_column("SKU", String(80), nullable=False)
    product_name: Mapped[str] = mapped_column("ProductName", String(250), nullable=False)
    category: Mapped[str | None] = mapped_column("Category", String(100), nullable=True)
    unit_price: Mapped[Decimal] = mapped_column("UnitPrice", Numeric(18, 4), nullable=False)
    stock_available: Mapped[int] = mapped_column("StockAvailable", Integer, nullable=False, default=0)
    delivery_lead_time_days: Mapped[int] = mapped_column(
        "DeliveryLeadTime_Days",
        Integer,
        nullable=False,
        default=0,
    )
    vector_embedding: Mapped[str] = mapped_column("VectorEmbedding", Text, nullable=False, default="")
    updated_at: Mapped[datetime] = mapped_column(
        "UpdatedAt",
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(UTC),
    )

    supplier: Mapped[SupplierProfile] = relationship(back_populates="catalogs")


class SupplierQualityScore(Base):
    """AI-service test-only table for ranking experiments until Sprint 5."""

    __tablename__ = "SupplierQualityScores"

    supplier_id: Mapped[int] = mapped_column(
        "SupplierID",
        ForeignKey("SupplierProfiles.SupplierID"),
        primary_key=True,
    )
    quality_score: Mapped[Decimal] = mapped_column("QualityScore", Numeric(5, 2), nullable=False)
    review_count: Mapped[int] = mapped_column("ReviewCount", Integer, nullable=False, default=0)
    average_rating: Mapped[Decimal] = mapped_column("AverageRating", Numeric(3, 2), nullable=False)
    on_time_delivery_rate: Mapped[Decimal] = mapped_column(
        "OnTimeDeliveryRate",
        Numeric(5, 4),
        nullable=False,
    )
    defect_rate: Mapped[Decimal] = mapped_column("DefectRate", Numeric(5, 4), nullable=False)
    computed_at: Mapped[datetime] = mapped_column(
        "ComputedAt",
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(UTC),
    )

    supplier: Mapped[SupplierProfile] = relationship(back_populates="quality_score")
