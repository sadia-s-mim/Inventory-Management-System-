<?php
session_start();
require_once 'config/database.php';
require_once 'config/constants.php';
require_once 'includes/functions.php';
require_once 'includes/auth_check.php';

$pageTitle = 'Dashboard';
$branchFilter = '';
$branchId = $_SESSION['branch_id'] ?? null;

$scopedBranch = null;
if ((int)$_SESSION['role_id'] !== ROLE_ADMIN) {
    $scopedBranch = $branchId;
}

// ---- KPI: Total products ----
$totalProducts = $conn->query("SELECT COUNT(*) c FROM products WHERE status='active'")->fetch_assoc()['c'];

// ---- KPI: Available stock (sum of quantities) ----
if ($scopedBranch) {
    $stmt = $conn->prepare("SELECT COALESCE(SUM(quantity),0) c FROM inventory WHERE branch_id = ?");
    $stmt->bind_param("i", $scopedBranch);
    $stmt->execute();
    $availableStock = $stmt->get_result()->fetch_assoc()['c'];
} else {
    $availableStock = $conn->query("SELECT COALESCE(SUM(quantity),0) c FROM inventory")->fetch_assoc()['c'];
}

// ---- KPI: Low stock alerts ----
if ($scopedBranch) {
    $sql = "SELECT COUNT(*) c FROM inventory i JOIN products p ON i.product_id=p.product_id WHERE i.quantity <= p.reorder_level AND i.branch_id = $scopedBranch";
} else {
    $sql = "SELECT COUNT(*) c FROM inventory i JOIN products p ON i.product_id=p.product_id WHERE i.quantity <= p.reorder_level";
}
$lowStockCount = $conn->query($sql)->fetch_assoc()['c'];

// ---- KPI: Inventory value (cost basis) ----
if ($scopedBranch) {
    $sql = "SELECT COALESCE(SUM(i.quantity * p.cost_price),0) v FROM inventory i JOIN products p ON i.product_id=p.product_id WHERE i.branch_id = $scopedBranch";
} else {
    $sql = "SELECT COALESCE(SUM(i.quantity * p.cost_price),0) v FROM inventory i JOIN products p ON i.product_id=p.product_id";
}
$inventoryValue = $conn->query($sql)->fetch_assoc()['v'];

// ---- KPI: Sales summary (last 30 days) ----
if ($scopedBranch) {
    $sql = "SELECT COALESCE(SUM(total_amount),0) v, COUNT(*) n FROM stock_out WHERE stock_out_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) AND branch_id = $scopedBranch";
} else {
    $sql = "SELECT COALESCE(SUM(total_amount),0) v, COUNT(*) n FROM stock_out WHERE stock_out_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)";
}
$salesRow = $conn->query($sql)->fetch_assoc();
$salesTotal30 = $salesRow['v'];
$salesCount30 = $salesRow['n'];

// ---- Chart: stock movement last 7 days ----
$labels = []; $inData = []; $outData = [];
for ($i = 6; $i >= 0; $i--) {
    $date = date('Y-m-d', strtotime("-$i days"));
    $labels[] = date('D', strtotime($date));

    $branchCond = $scopedBranch ? " AND branch_id = $scopedBranch" : "";
    $in = $conn->query("SELECT COALESCE(SUM(sid.quantity),0) v FROM stock_in si JOIN stock_in_details sid ON si.stock_in_id = sid.stock_in_id WHERE si.stock_in_date = '$date'" . $branchCond)->fetch_assoc()['v'];
    $out = $conn->query("SELECT COALESCE(SUM(sod.quantity),0) v FROM stock_out so JOIN stock_out_details sod ON so.stock_out_id = sod.stock_out_id WHERE so.stock_out_date = '$date'" . $branchCond)->fetch_assoc()['v'];
    $inData[] = (int)$in;
    $outData[] = (int)$out;
}

// ---- Recent activity ----
$recentActivity = $conn->query("SELECT al.*, u.full_name FROM activity_logs al LEFT JOIN users u ON al.user_id = u.user_id ORDER BY al.created_at DESC LIMIT 8");

// ---- Low stock list (for quick table) ----
if ($scopedBranch) {
    $lowStockList = $conn->query("SELECT p.product_name, p.sku, i.quantity, p.reorder_level, b.branch_name
        FROM inventory i JOIN products p ON i.product_id = p.product_id JOIN branches b ON i.branch_id = b.branch_id
        WHERE i.quantity <= p.reorder_level AND i.branch_id = $scopedBranch ORDER BY i.quantity ASC LIMIT 6");
} else {
    $lowStockList = $conn->query("SELECT p.product_name, p.sku, i.quantity, p.reorder_level, b.branch_name
        FROM inventory i JOIN products p ON i.product_id = p.product_id JOIN branches b ON i.branch_id = b.branch_id
        WHERE i.quantity <= p.reorder_level ORDER BY i.quantity ASC LIMIT 6");
}

require_once 'includes/header.php';
require_once 'includes/sidebar.php';
?>

<div class="row g-3 mb-4">
    <div class="col-md-3">
        <div class="pc-kpi">
            <div class="kpi-label">Total Products</div>
            <div class="kpi-value"><?php echo number_format($totalProducts); ?></div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="pc-kpi alt1">
            <div class="kpi-label">Available Stock</div>
            <div class="kpi-value"><?php echo number_format($availableStock); ?></div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="pc-kpi alt2">
            <div class="kpi-label">Low Stock Alerts</div>
            <div class="kpi-value"><?php echo number_format($lowStockCount); ?></div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="pc-kpi alt3">
            <div class="kpi-label">Inventory Value</div>
            <div class="kpi-value">৳<?php echo formatMoney($inventoryValue); ?></div>
        </div>
    </div>
</div>

<div class="row g-3 mb-4">
    <div class="col-md-8">
        <div class="pc-card p-3">
            <h6 class="mb-3">Stock Movement — Last 7 Days</h6>
            <canvas id="stockMovementChart" height="110"></canvas>
        </div>
    </div>
    <div class="col-md-4">
        <div class="pc-card p-3 h-100">
            <h6 class="mb-3">Sales Summary (30 days)</h6>
            <div class="mb-2"><span class="text-muted">Total Sales:</span> <strong>৳<?php echo formatMoney($salesTotal30); ?></strong></div>
            <div><span class="text-muted">Transactions:</span> <strong><?php echo number_format($salesCount30); ?></strong></div>
        </div>
    </div>
</div>

<div class="row g-3">
    <div class="col-md-6">
        <div class="pc-card p-3">
            <h6 class="mb-3"><i class="bi bi-exclamation-triangle text-danger"></i> Low Stock Items</h6>
            <table class="table table-sm table-hover mb-0">
                <thead><tr><th>Product</th><th>Branch</th><th>Qty</th><th>Reorder Lvl</th></tr></thead>
                <tbody>
                <?php if ($lowStockList->num_rows === 0): ?>
                    <tr><td colspan="4" class="text-muted text-center py-3">No low stock items 🎉</td></tr>
                <?php else: while ($row = $lowStockList->fetch_assoc()): ?>
                    <tr>
                        <td><?php echo htmlspecialchars($row['product_name']); ?></td>
                        <td><?php echo htmlspecialchars($row['branch_name']); ?></td>
                        <td><span class="badge badge-low"><?php echo $row['quantity']; ?></span></td>
                        <td><?php echo $row['reorder_level']; ?></td>
                    </tr>
                <?php endwhile; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
    <div class="col-md-6">
        <div class="pc-card p-3">
            <h6 class="mb-3"><i class="bi bi-clock-history"></i> Recent Activity</h6>
            <ul class="list-unstyled mb-0">
                <?php while ($a = $recentActivity->fetch_assoc()): ?>
                    <li class="d-flex justify-content-between border-bottom py-2">
                        <span><strong><?php echo htmlspecialchars($a['full_name'] ?? 'System'); ?></strong> — <?php echo htmlspecialchars($a['action']); ?></span>
                        <small class="text-muted"><?php echo date('M d, h:i A', strtotime($a['created_at'])); ?></small>
                    </li>
                <?php endwhile; ?>
            </ul>
        </div>
    </div>
</div>

    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js"></script>
<script>
const ctx = document.getElementById('stockMovementChart');
new Chart(ctx, {
    type: 'bar',
    data: {
        labels: <?php echo json_encode($labels); ?>,
        datasets: [
            { label: 'Stock In', data: <?php echo json_encode($inData); ?>, backgroundColor: '#a98a4d' },
            { label: 'Stock Out', data: <?php echo json_encode($outData); ?>, backgroundColor: '#5c4433' }
        ]
    },
    options: { responsive: true, plugins: { legend: { position: 'bottom' } } }
});
</script>

<?php require_once 'includes/footer.php'; ?>
