<?php
session_start();
require_once '../config/database.php';
require_once '../config/constants.php';
require_once '../includes/functions.php';
require_once '../includes/auth_check.php';

$pageTitle = 'Current Inventory Report';
$scopedBranch = ((int)$_SESSION['role_id'] !== ROLE_ADMIN) ? $_SESSION['branch_id'] : null;

$sql = "SELECT p.product_name, p.sku, c.category_name, b.branch_name, i.quantity, p.cost_price, p.selling_price,
        (i.quantity * p.cost_price) AS stock_value
        FROM inventory i
        JOIN products p ON i.product_id = p.product_id
        JOIN branches b ON i.branch_id = b.branch_id
        LEFT JOIN categories c ON p.category_id = c.category_id";
if ($scopedBranch) $sql .= " WHERE i.branch_id = $scopedBranch";
$sql .= " ORDER BY p.product_name";
$rows = $conn->query($sql);

$totalValueSql = "SELECT COALESCE(SUM(i.quantity * p.cost_price),0) v FROM inventory i JOIN products p ON i.product_id=p.product_id";
if ($scopedBranch) $totalValueSql .= " WHERE i.branch_id = $scopedBranch";
$totalValue = $conn->query($totalValueSql)->fetch_assoc()['v'];

require_once '../includes/header.php';
require_once '../includes/sidebar.php';
require_once 'reports_nav.php';
?>

<div class="pc-card p-3 mb-3 d-flex justify-content-between align-items-center">
    <div><strong>Total Inventory Value:</strong> ৳<?php echo formatMoney($totalValue); ?></div>
    <button onclick="window.print()" class="btn btn-sm btn-outline-secondary"><i class="bi bi-printer"></i> Print</button>
</div>

<div class="pc-card p-3">
    <table class="table table-hover align-middle mb-0">
        <thead><tr><th>Product</th><th>SKU</th><th>Type</th><th>Branch</th><th>Qty on Hand</th><th>Cost Price</th><th>Selling Price</th><th>Stock Value</th></tr></thead>
        <tbody>
        <?php if ($rows->num_rows === 0): ?>
            <tr><td colspan="8" class="text-center text-muted py-4">No inventory data.</td></tr>
        <?php else: while ($r = $rows->fetch_assoc()): ?>
            <tr>
                <td><?php echo htmlspecialchars($r['product_name']); ?></td>
                <td><?php echo htmlspecialchars($r['sku']); ?></td>
                <td><?php echo htmlspecialchars($r['category_name'] ?? '—'); ?></td>
                <td><?php echo htmlspecialchars($r['branch_name']); ?></td>
                <td><?php echo $r['quantity']; ?></td>
                <td>৳<?php echo formatMoney($r['cost_price']); ?></td>
                <td>৳<?php echo formatMoney($r['selling_price']); ?></td>
                <td>৳<?php echo formatMoney($r['stock_value']); ?></td>
            </tr>
        <?php endwhile; endif; ?>
        </tbody>
    </table>
</div>

    </main>
</div>
<?php require_once '../includes/footer.php'; ?>
