using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Salasel.API.Controllers;

public class ResourcePermissionDto
{
    public string Key { get; set; } = "";
    public string Name { get; set; } = "";
    public string Description { get; set; } = "";
    public bool Read { get; set; }
    public bool Write { get; set; }
    public bool Delete { get; set; }
    public bool Approve { get; set; }
}

public class SupplierRoleDto
{
    public string RoleName { get; set; } = "";
    public List<ResourcePermissionDto> Resources { get; set; } = new();
}

[ApiController]
[Route("api/v1/suppliers/roles")]
[Authorize(Roles = "Supplier,Admin")]
public class SupplierRolesController : ControllerBase
{
    // For MVP purposes, we're using a static in-memory dictionary.
    // In production, this should be moved to EF Core with proper migrations.
    private static readonly Dictionary<int, List<SupplierRoleDto>> _mockDb = new();

    private int GetSupplierId()
    {
        var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return int.TryParse(idStr, out var id) ? id : 0;
    }

    [HttpGet]
    public IActionResult GetRoles()
    {
        var supplierId = GetSupplierId();
        if (supplierId == 0) return Unauthorized();

        if (!_mockDb.ContainsKey(supplierId))
        {
            // Seed default roles
            _mockDb[supplierId] = new List<SupplierRoleDto>
            {
                new SupplierRoleDto
                {
                    RoleName = "موظف مستودع",
                    Resources = GetDefaultResources(readOnly: true)
                },
                new SupplierRoleDto
                {
                    RoleName = "مدير مشتريات",
                    Resources = GetDefaultResources(readOnly: false)
                }
            };
        }

        return Ok(_mockDb[supplierId]);
    }

    [HttpPost]
    public IActionResult SaveRoles([FromBody] List<SupplierRoleDto> roles)
    {
        var supplierId = GetSupplierId();
        if (supplierId == 0) return Unauthorized();

        if (roles == null || !roles.Any())
            return BadRequest(new { error = "Roles cannot be empty." });

        _mockDb[supplierId] = roles;

        return Ok(new { message = "Roles updated successfully." });
    }

    private List<ResourcePermissionDto> GetDefaultResources(bool readOnly)
    {
        return new List<ResourcePermissionDto>
        {
            new ResourcePermissionDto { Key = "orders", Name = "الطلبات", Description = "طلبات شراء العملاء وحالات التنفيذ.", Read = true, Write = !readOnly, Delete = false, Approve = !readOnly },
            new ResourcePermissionDto { Key = "catalog", Name = "الكتالوج", Description = "قوائم المنتجات والأوصاف ومستويات المخزون.", Read = true, Write = !readOnly, Delete = false, Approve = false },
            new ResourcePermissionDto { Key = "suppliers", Name = "الموردين", Description = "إدارة بيانات الموردين وعقود التوريد.", Read = true, Write = false, Delete = false, Approve = false },
            new ResourcePermissionDto { Key = "warehouses", Name = "المستودعات", Description = "التحكم في مواقع التخزين وحركات المخزون.", Read = true, Write = !readOnly, Delete = false, Approve = false },
            new ResourcePermissionDto { Key = "finance", Name = "التقارير المالية", Description = "الوصول إلى الميزانيات والتقارير الضريبية.", Read = !readOnly, Write = false, Delete = false, Approve = false },
            new ResourcePermissionDto { Key = "users", Name = "إدارة المستخدمين", Description = "إضافة وتعديل حسابات الموظفين وصلاحياتهم.", Read = !readOnly, Write = !readOnly, Delete = false, Approve = false },
            new ResourcePermissionDto { Key = "system", Name = "إعدادات النظام", Description = "تكوين المعلمات الأساسية للنظام والواجهات.", Read = true, Write = false, Delete = false, Approve = false }
        };
    }
}
