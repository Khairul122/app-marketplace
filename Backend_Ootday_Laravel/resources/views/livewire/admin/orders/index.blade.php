<div class="space-y-6">
    @if (session('success'))
        <div class="hidden alert-flash-data" data-id="success-{{ session('success') }}-{{ uniqid() }}" data-type="success" data-message="{{ session('success') }}"></div>
    @endif
    @if ($errors->any())
        <div class="hidden alert-flash-data" data-id="error-{{ $errors->first() }}-{{ uniqid() }}" data-type="error" data-message="{{ $errors->first() }}"></div>
    @endif

    <!-- Toolbar Filters -->
    <div class="flex flex-col sm:flex-row gap-4 bg-white p-4 rounded-2xl border border-slate-100 shadow-sm">
        <input type="text" wire:model.live.debounce.300ms="search" placeholder="Cari kode pesanan..."
            class="rounded-xl border border-slate-200 px-4 py-2.5 text-sm bg-slate-50/50 focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200 w-full sm:max-w-sm">
        <select wire:model.live="statusFilter" class="rounded-xl border border-slate-200 px-4 py-2.5 text-sm bg-white focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200 min-w-[200px]">
            <option value="">Semua Status</option>
            @foreach ($statuses as $status)
                <option value="{{ $status }}">{{ str_replace('_', ' ', $status) }}</option>
            @endforeach
        </select>
    </div>

    <!-- Table List -->
    <div class="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
        <table class="w-full text-sm text-left">
            <thead class="bg-slate-50/75 border-b border-slate-100 text-slate-400 text-xs font-bold uppercase tracking-wider">
                <tr>
                    <th class="px-6 py-4">Kode Pesanan</th>
                    <th class="px-6 py-4">Toko</th>
                    <th class="px-6 py-4">Pembeli</th>
                    <th class="px-6 py-4">Total Tagihan</th>
                    <th class="px-6 py-4">Status Transaksi</th>
                    <th class="px-6 py-4">Tanggal Order</th>
                    <th class="px-6 py-4"></th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                @forelse ($orders as $order)
                    <tr class="hover:bg-slate-50/50 transition-colors">
                        <td class="px-6 py-4 font-black text-rose-500">#{{ $order->order_code }}</td>
                        <td class="px-6 py-4 text-slate-600 font-bold">{{ $order->store->store_name ?? '-' }}</td>
                        <td class="px-6 py-4 text-slate-600 font-medium">{{ $order->user->name ?? '-' }}</td>
                        <td class="px-6 py-4 text-slate-800 font-extrabold tabular-nums">Rp {{ number_format($order->total_price, 0, ',', '.') }}</td>
                        <td class="px-6 py-4">
                            @php
                                $statusColors = match($order->status) {
                                    'menunggu_pembayaran' => 'bg-amber-50 text-amber-600 border-amber-200/50',
                                    'diproses' => 'bg-sky-50 text-sky-600 border-sky-200/50',
                                    'dikirim' => 'bg-indigo-50 text-indigo-600 border-indigo-200/50',
                                    'selesai' => 'bg-emerald-50 text-emerald-600 border-emerald-200/50',
                                    default => 'bg-rose-50 text-rose-600 border-rose-200/50',
                                };
                            @endphp
                            <select wire:change="updateStatus({{ $order->id }}, $event.target.value)"
                                class="text-xs font-bold rounded-full border px-3 py-1 bg-white focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 {{ $statusColors }}">
                                @foreach ($statuses as $status)
                                    <option class="bg-white text-slate-800 font-semibold" value="{{ $status }}" @selected($order->status === $status)>{{ str_replace('_', ' ', $status) }}</option>
                                @endforeach
                            </select>
                        </td>
                        <td class="px-6 py-4 text-slate-500 font-medium">{{ $order->ordered_at->format('d M Y H:i') }}</td>
                        <td class="px-6 py-4 text-right space-x-3 whitespace-nowrap">
                            <button wire:click="view({{ $order->id }})" class="text-xs font-bold text-slate-400 hover:text-rose-500 active:scale-95 transition">Detail</button>
                            @if ($confirmingDeleteId === $order->id)
                                <button wire:click="delete({{ $order->id }})" class="text-xs font-black text-rose-600 hover:underline active:scale-95 transition-transform">Yakin?</button>
                                <button wire:click="cancelDelete" class="text-xs font-bold text-slate-400 hover:text-slate-600 active:scale-95 transition">Batal</button>
                            @else
                                <button wire:click="confirmDelete({{ $order->id }})" class="text-xs font-bold text-rose-500 hover:text-rose-600 active:scale-95 transition">Hapus</button>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="7" class="px-6 py-16">
                            <div class="flex flex-col items-center justify-center gap-3 text-center">
                                <div class="w-14 h-14 rounded-2xl bg-indigo-50 flex items-center justify-center text-indigo-300">
                                    <svg class="w-7 h-7" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"></path></svg>
                                </div>
                                <div>
                                    <p class="text-sm font-bold text-slate-500">Belum ada pesanan masuk</p>
                                    <p class="text-xs text-slate-400 mt-0.5">Transaksi pelanggan akan otomatis muncul di sini.</p>
                                </div>
                            </div>
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <div class="pt-2">{{ $orders->links() }}</div>

    <!-- Detail Modal -->
    @if ($viewingOrder)
        <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-md flex items-center justify-center z-50 animate-overlay-fade" wire:click.self="closeView">
            <div class="bg-white rounded-3xl shadow-xl border border-slate-50 p-8 animate-modal-pop w-full max-w-lg space-y-5 max-h-[80vh] overflow-y-auto transform scale-100 transition-all duration-300">
                <div class="flex items-center justify-between border-b border-slate-50 pb-3">
                    <div>
                        <h3 class="font-black text-xl text-slate-800">#{{ $viewingOrder->order_code }}</h3>
                        <p class="text-xs text-slate-400 font-medium">{{ $viewingOrder->store->store_name ?? '-' }} &middot; Pembeli: {{ $viewingOrder->user->name ?? '-' }}</p>
                    </div>
                    @php
                        $badgeColors = match($viewingOrder->status) {
                            'menunggu_pembayaran' => 'bg-amber-50 text-amber-600 border-amber-100/50',
                            'diproses' => 'bg-sky-50 text-sky-600 border-sky-100/50',
                            'dikirim' => 'bg-indigo-50 text-indigo-600 border-indigo-100/50',
                            'selesai' => 'bg-emerald-50 text-emerald-600 border-emerald-100/50',
                            default => 'bg-rose-50 text-rose-600 border-rose-100/50',
                        };
                    @endphp
                    <span class="px-3 py-1 rounded-full text-xs font-bold capitalize {{ $badgeColors }}">
                        {{ str_replace('_', ' ', $viewingOrder->status) }}
                    </span>
                </div>

                <div class="grid grid-cols-2 gap-4 text-xs font-medium bg-slate-50 p-4 rounded-2xl border border-slate-100">
                    <div>
                        <span class="text-slate-400 block mb-0.5">Metode Pembayaran</span>
                        <span class="text-slate-800 font-bold text-sm">{{ $viewingOrder->paymentMethod->name ?? '-' }}</span>
                    </div>
                    <div>
                        <span class="text-slate-400 block mb-0.5">Jasa Pengiriman</span>
                        <span class="text-slate-800 font-bold text-sm">{{ $viewingOrder->shippingMethod->name ?? '-' }}</span>
                    </div>
                </div>

                <div class="space-y-2 pt-2">
                    <span class="text-slate-400 text-xs uppercase font-bold tracking-wider block">Item Pesanan:</span>
                    <div class="border border-slate-100 rounded-2xl overflow-hidden">
                        <table class="w-full text-xs text-left">
                            <thead class="bg-slate-50/75 border-b border-slate-100 text-slate-400 font-bold">
                                <tr>
                                    <th class="px-4 py-3">Produk</th>
                                    <th class="px-4 py-3">Varian</th>
                                    <th class="px-4 py-3 text-center">Qty</th>
                                    <th class="px-4 py-3 text-right">Harga Satuan</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100/50 font-semibold text-slate-700">
                                @foreach ($viewingOrder->items as $item)
                                    <tr>
                                        <td class="px-4 py-3 text-slate-800 font-bold">{{ $item->product_name }}</td>
                                        <td class="px-4 py-3 text-slate-500 font-medium">{{ $item->variant_label }}</td>
                                        <td class="px-4 py-3 text-center font-bold text-slate-800">{{ $item->quantity }}</td>
                                        <td class="px-4 py-3 text-right text-slate-800 font-bold">Rp {{ number_format($item->price, 0, ',', '.') }}</td>
                                    </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Total Bill Breakdown -->
                <div class="text-sm text-slate-600 font-medium space-y-2 pt-3 border-t border-slate-100">
                    <div class="flex justify-between">
                        <span class="text-slate-400">Subtotal Item</span>
                        <span class="text-slate-800 font-bold">Rp {{ number_format($viewingOrder->subtotal, 0, ',', '.') }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-slate-400">Biaya Pengiriman (Ongkir)</span>
                        <span class="text-slate-800 font-bold">Rp {{ number_format($viewingOrder->shipping_cost, 0, ',', '.') }}</span>
                    </div>
                    <div class="flex justify-between font-black text-base pt-2 border-t border-slate-50">
                        <span class="text-slate-800">Total Pembayaran</span>
                        <span class="text-rose-500 font-black text-lg">Rp {{ number_format($viewingOrder->total_price, 0, ',', '.') }}</span>
                    </div>
                </div>

                <div class="flex justify-end pt-2">
                    <button wire:click="closeView" class="w-full px-5 py-3 text-sm font-bold text-slate-500 hover:text-slate-700 bg-slate-50 hover:bg-slate-100 rounded-xl transition-all duration-200">
                        Tutup Rincian
                    </button>
                </div>
            </div>
        </div>
    @endif
</div>
