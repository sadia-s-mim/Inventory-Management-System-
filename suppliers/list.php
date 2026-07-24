<?php
session_start();
require_once '../config/database.php';
require_once '../config/constants.php';
require_once '../includes/functions.php';
require_once '../includes/auth_check.php';
requireRole([ROLE_ADMIN, ROLE_BRANCH_MANAGER]);

$pageTitle = 'Suppliers';
$search = sanitize($conn, $_GET['search'] ?? '');

$sql = "SELECT * FROM suppliers WHERE 1=1";
if ($search !== '') {
    $sql .= " AND (supplier_name LIKE '%$search%' OR contact_person LIKE '%$search%')";
}
$sql .= " ORDER BY supplier_name";
$suppliers = $conn->query($sql);

require_once '../includes/header.php';
require_once '../includes/sidebar.php';
?>

<div class="d-flex justify-content-between align-items-center mb-3">
    <form class="d-flex gap-2" method="GET">
        <input type="text" name="search" class="form-control" placeholder="Search suppliers" value="<?php echo htmlspecialchars($search); ?>">
        <button class="btn btn-pc-primary"><i class="bi bi-search"></i></button>
    </form>
    <a href="add.php" class="btn btn-pc-gold"><i class="bi bi-plus-lg"></i> Add Supplier</a>
</div>

<div class="pc-card p-3">
    <table class="table table-hover align-middle mb-0">
        <thead>
            <tr><th>Name</th><th>Contact Person</th><th>Phone</th><th>Email</th><th>Address</th><th>Status</th><th></th></tr>
        </thead>
        <tbody>
        <?php if ($suppliers->num_rows === 0): ?>
            <tr><td colspan="7" class="text-center text-muted py-4">No suppliers found.</td></tr>
        <?php else: while ($s = $suppliers->fetch_assoc()): ?>
            <tr>
                <td><?php echo htmlspecialchars($s['supplier_name']); ?></td>
                <td><?php echo htmlspecialchars($s['contact_person']); ?></td>
                <td><?php echo htmlspecialchars($s['phone']); ?></td>
                <td><?php echo htmlspecialchars($s['email']); ?></td>
                <td><?php echo htmlspecialchars($s['address']); ?></td>
                <td><span class="badge <?php echo $s['status']==='active'?'badge-ok':'bg-secondary'; ?>"><?php echo ucfirst($s['status']); ?></span></td>
                <td class="text-end">
                    <a href="edit.php?id=<?php echo $s['supplier_id']; ?>" class="btn btn-sm btn-outline-secondary"><i class="bi bi-pencil"></i></a>
                    <?php if ((int)$_SESSION['role_id'] === ROLE_ADMIN): ?>
                    <a href="delete.php?id=<?php echo $s['supplier_id']; ?>" class="btn btn-sm btn-outline-danger pc-confirm-delete"><i class="bi bi-trash"></i></a>
                    <?php endif; ?>
                </td>
            </tr>
        <?php endwhile; endif; ?>
        </tbody>
    </table>
</div>

    </main>
</div>
<?php require_once '../includes/footer.php'; ?>
