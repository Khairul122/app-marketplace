<div class="space-y-8">
    <!-- Metric Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <!-- Users Card -->
        <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 hover:shadow-md hover:scale-[1.01] transition-all duration-300 flex items-start justify-between">
            <div class="space-y-2">
                <p class="text-xs font-bold text-slate-400 tracking-wider uppercase">Total Users</p>
                <h3 class="text-3xl font-black text-slate-800 tabular-nums">{{ $totalUsers }}</h3>
                <p class="text-xs text-slate-400 font-medium pt-1">
                    <span class="text-rose-500 font-bold">{{ $usersByRole['owner'] ?? 0 }}</span> penjual &middot; <span class="text-emerald-500 font-bold">{{ $usersByRole['pelanggan'] ?? 0 }}</span> pembeli
                </p>
            </div>
            <div class="p-3 bg-violet-50 text-violet-500 rounded-xl">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path></svg>
            </div>
        </div>

        <!-- Stores Card -->
        <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 hover:shadow-md hover:scale-[1.01] transition-all duration-300 flex items-start justify-between">
            <div class="space-y-2">
                <p class="text-xs font-bold text-slate-400 tracking-wider uppercase">Total Toko</p>
                <h3 class="text-3xl font-black text-slate-800 tabular-nums">{{ $totalStores }}</h3>
                <p class="text-xs text-slate-400 font-medium pt-1">Mitra Toko Terdaftar</p>
            </div>
            <div class="p-3 bg-amber-50 text-amber-500 rounded-xl">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path></svg>
            </div>
        </div>

        <!-- Products Card -->
        <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 hover:shadow-md hover:scale-[1.01] transition-all duration-300 flex items-start justify-between">
            <div class="space-y-2">
                <p class="text-xs font-bold text-slate-400 tracking-wider uppercase">Total Produk</p>
                <h3 class="text-3xl font-black text-slate-800 tabular-nums">{{ $totalProducts }}</h3>
                <p class="text-xs text-slate-400 font-medium pt-1">Katalog Produk Aktif</p>
            </div>
            <div class="p-3 bg-sky-50 text-sky-500 rounded-xl">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path></svg>
            </div>
        </div>

        <!-- Revenue Card -->
        <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-6 hover:shadow-md hover:scale-[1.01] transition-all duration-300 flex items-start justify-between">
            <div class="space-y-2">
                <p class="text-xs font-bold text-slate-400 tracking-wider uppercase">Revenue (Selesai)</p>
                <h3 class="text-3xl font-black text-rose-500 tabular-nums">Rp {{ number_format($revenue, 0, ',', '.') }}</h3>
                <p class="text-xs text-slate-400 font-medium pt-1">Transaksi Selesai</p>
            </div>
            <div class="p-3 bg-rose-50 text-rose-500 rounded-xl">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M12 16v1m-10-5h4M8 12h8m2 0h4"></path></svg>
            </div>
        </div>
    </div>

    <!-- Orders Status Analytics -->
    <div class="bg-white rounded-2xl border border-slate-100 shadow-sm p-8 space-y-6">
        <div class="flex items-center justify-between border-b border-slate-50 pb-4">
            <div>
                <h2 class="text-base font-bold text-slate-800">Status Pesanan</h2>
                <p class="text-xs text-slate-400 font-medium">Distribusi total {{ $totalOrders }} pesanan pelanggan</p>
            </div>
            <span class="text-xs font-bold bg-slate-50 text-slate-500 px-3 py-1.5 rounded-lg border border-slate-100">Live Update</span>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-6">
            @foreach ($ordersByStatus as $status => $count)
                @php
                    $colors = match($status) {
                        'menunggu_pembayaran' => ['bg' => 'bg-amber-50', 'text' => 'text-amber-600', 'bar' => 'bg-amber-500'],
                        'diproses' => ['bg' => 'bg-sky-50', 'text' => 'text-sky-600', 'bar' => 'bg-sky-500'],
                        'dikirim' => ['bg' => 'bg-indigo-50', 'text' => 'text-indigo-600', 'bar' => 'bg-indigo-500'],
                        'selesai' => ['bg' => 'bg-emerald-50', 'text' => 'text-emerald-600', 'bar' => 'bg-emerald-500'],
                        default => ['bg' => 'bg-rose-50', 'text' => 'text-rose-600', 'bar' => 'bg-rose-500'],
                    };
                    $percentage = $totalOrders > 0 ? ($count / $totalOrders) * 100 : 0;
                @endphp
                <div class="p-5 rounded-xl {{ $colors['bg'] }} border border-transparent hover:border-slate-100/50 transition-all duration-200 space-y-3">
                    <div class="flex items-center justify-between">
                        <span class="text-xs font-bold capitalize {{ $colors['text'] }}">{{ str_replace('_', ' ', $status) }}</span>
                        <span class="text-sm font-black tabular-nums {{ $colors['text'] }}">{{ $count }}</span>
                    </div>
                    <div class="w-full bg-slate-200/50 h-2 rounded-full overflow-hidden">
                        <div class="h-full {{ $colors['bar'] }} rounded-full" style="width: {{ $percentage }}%"></div>
                    </div>
                    <p class="text-[10px] text-slate-400 font-semibold">{{ number_format($percentage, 1) }}% dari total pesanan</p>
                </div>
            @endforeach
        </div>
    </div>
</div>
