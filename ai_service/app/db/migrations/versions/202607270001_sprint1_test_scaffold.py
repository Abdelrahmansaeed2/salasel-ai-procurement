"""create sprint 1 ai service test scaffold

Revision ID: 202607270001
Revises:
Create Date: 2026-07-27 00:01:00
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa

revision: str = "202607270001"
down_revision: str | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "SupplierProfiles",
        sa.Column("SupplierID", sa.Integer(), sa.Identity(start=1), nullable=False),
        sa.Column("CompanyName", sa.String(length=200), nullable=False),
        sa.Column("ReliabilityScore", sa.Numeric(precision=5, scale=2), nullable=False),
        sa.Column("PaymentTerms", sa.String(length=100), nullable=False),
        sa.Column("IsActiveForRouting", sa.Boolean(), nullable=False),
        sa.Column("Latitude", sa.Float(), nullable=True),
        sa.Column("Longitude", sa.Float(), nullable=True),
        sa.PrimaryKeyConstraint("SupplierID"),
    )
    op.execute("ALTER TABLE SupplierProfiles ADD Location GEOGRAPHY NULL")
    op.execute("CREATE SPATIAL INDEX IX_SupplierProfiles_Location ON SupplierProfiles(Location)")
    op.create_table(
        "SupplierCatalogs",
        sa.Column("CatalogID", sa.Integer(), sa.Identity(start=1), nullable=False),
        sa.Column("SupplierID", sa.Integer(), nullable=False),
        sa.Column("SKU", sa.String(length=80), nullable=False),
        sa.Column("ProductName", sa.String(length=250), nullable=False),
        sa.Column("UnitPrice", sa.Numeric(precision=18, scale=4), nullable=False),
        sa.Column("StockAvailable", sa.Integer(), nullable=False),
        sa.Column("DeliveryLeadTime_Days", sa.Integer(), nullable=False),
        sa.Column("VectorEmbedding", sa.Text(), nullable=False),
        sa.Column("UpdatedAt", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["SupplierID"], ["SupplierProfiles.SupplierID"]),
        sa.PrimaryKeyConstraint("CatalogID"),
    )
    op.create_index(
        op.f("ix_SupplierCatalogs_SupplierID"),
        "SupplierCatalogs",
        ["SupplierID"],
        unique=False,
    )
    op.create_table(
        "SupplierQualityScores",
        sa.Column("SupplierID", sa.Integer(), nullable=False),
        sa.Column("QualityScore", sa.Numeric(precision=5, scale=2), nullable=False),
        sa.Column("ReviewCount", sa.Integer(), nullable=False),
        sa.Column("AverageRating", sa.Numeric(precision=3, scale=2), nullable=False),
        sa.Column("OnTimeDeliveryRate", sa.Numeric(precision=5, scale=4), nullable=False),
        sa.Column("DefectRate", sa.Numeric(precision=5, scale=4), nullable=False),
        sa.Column("ComputedAt", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["SupplierID"], ["SupplierProfiles.SupplierID"]),
        sa.PrimaryKeyConstraint("SupplierID"),
    )


def downgrade() -> None:
    op.drop_table("SupplierQualityScores")
    op.drop_index(op.f("ix_SupplierCatalogs_SupplierID"), table_name="SupplierCatalogs")
    op.drop_table("SupplierCatalogs")
    op.drop_table("SupplierProfiles")
