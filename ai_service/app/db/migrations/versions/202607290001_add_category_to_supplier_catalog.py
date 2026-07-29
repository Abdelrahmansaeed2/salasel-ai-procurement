"""add Category column to SupplierCatalogs

Revision ID: 202607290001
Revises: 202607270001
Create Date: 2026-07-29 00:01:00
"""

from collections.abc import Sequence

from alembic import op
import sqlalchemy as sa

revision: str = "202607290001"
down_revision: str | None = "202607270001"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column("SupplierCatalogs", sa.Column("Category", sa.String(length=100), nullable=True))


def downgrade() -> None:
    op.drop_column("SupplierCatalogs", "Category")
