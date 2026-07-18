<div class="space-y-6">
    @if (session('success'))
        <div class="hidden alert-flash-data" data-id="success-{{ session('success') }}-{{ uniqid() }}" data-type="success" data-message="{{ session('success') }}"></div>
    @endif
    @if ($errors->any())
        <div class="hidden alert-flash-data" data-id="error-{{ $errors->first() }}-{{ uniqid() }}" data-type="error" data-message="{{ $errors->first() }}"></div>
    @endif

    <!-- Toolbar Filters -->
    <div class="flex flex-col lg:flex-row gap-4 justify-between items-start lg:items-center bg-white p-4 rounded-2xl border border-slate-100 shadow-sm">
        <div class="flex flex-col sm:flex-row gap-3 w-full lg:w-auto">
            <input type="text" wire:model.live.debounce.300ms="search" placeholder="Cari produk..."
                class="rounded-xl border border-slate-200 px-4 py-2.5 text-sm bg-slate-50/50 focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200 min-w-[240px]">
            <select wire:model.live="storeFilter" class="rounded-xl border border-slate-200 px-4 py-2.5 text-sm bg-white focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200 min-w-[160px]">
                <option value="">Semua Toko</option>
                @foreach ($stores as $store)
                    <option value="{{ $store->id }}">{{ $store->store_name }}</option>
                @endforeach
            </select>
            <select wire:model.live="statusFilter" class="rounded-xl border border-slate-200 px-4 py-2.5 text-sm bg-white focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200 min-w-[140px]">
                <option value="">Semua Status</option>
                <option value="active">Aktif</option>
                <option value="inactive">Nonaktif</option>
            </select>
        </div>
        <button wire:click="create" class="px-5 py-2.5 text-sm font-bold bg-gradient-to-r from-rose-500 to-pink-500 hover:from-rose-600 hover:to-pink-600 text-white rounded-xl shadow-md shadow-rose-500/15 hover:shadow-lg hover:scale-[1.02] active:scale-[0.98] transition-all duration-200 whitespace-nowrap">
            + Tambah Produk
        </button>
    </div>

    <!-- Table List -->
    <div class="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
        <table class="w-full text-sm text-left">
            <thead class="bg-slate-50/75 border-b border-slate-100 text-slate-400 text-xs font-bold uppercase tracking-wider">
                <tr>
                    <th class="px-6 py-4">Produk</th>
                    <th class="px-6 py-4">Toko</th>
                    <th class="px-6 py-4">Kategori</th>
                    <th class="px-6 py-4">Harga</th>
                    <th class="px-6 py-4 text-center">Stok</th>
                    <th class="px-6 py-4">Status</th>
                    <th class="px-6 py-4"></th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                @forelse ($products as $product)
                    <tr class="hover:bg-slate-50/50 transition-colors">
                        <td class="px-6 py-4 font-bold text-slate-800 flex items-center gap-3">
                            <div class="w-10 h-10 rounded-xl overflow-hidden bg-slate-50 border border-slate-100 flex-shrink-0 flex items-center justify-center">
                                @if($product->images->isNotEmpty())
                                    <img src="{{ $product->images->first()->image_url }}" alt="Foto produk {{ $product->name }}" class="w-full h-full object-cover">
                                @else
                                    <svg class="w-5 h-5 text-slate-300" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                                @endif
                            </div>
                            <span>{{ $product->name }}</span>
                        </td>
                        <td class="px-6 py-4 text-slate-600 font-medium">{{ $product->store->store_name ?? '-' }}</td>
                        <td class="px-6 py-4 text-slate-600 font-medium">{{ $product->category->name ?? '-' }}</td>
                        <td class="px-6 py-4 text-slate-700 font-bold tabular-nums">Rp {{ number_format($product->price, 0, ',', '.') }}</td>
                        <td class="px-6 py-4 text-center text-slate-600 font-medium tabular-nums">{{ $product->stock }}</td>
                        <td class="px-6 py-4">
                            <span class="px-2.5 py-1 rounded-full text-xs font-bold {{ $product->status === 'active' ? 'bg-green-50 text-green-600 border border-green-100/50' : 'bg-slate-100 text-slate-500' }}">
                                {{ $product->status === 'active' ? 'Aktif' : 'Nonaktif' }}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-right space-x-3 whitespace-nowrap">
                            <button wire:click="view({{ $product->id }})" class="text-xs font-bold text-slate-400 hover:text-rose-500 active:scale-95 transition">Detail</button>
                            <button wire:click="edit({{ $product->id }})" class="text-xs font-bold text-slate-600 hover:text-rose-500 active:scale-95 transition">Edit</button>
                            @if ($confirmingDeleteId === $product->id)
                                <button wire:click="delete({{ $product->id }})" class="text-xs font-black text-rose-600 hover:underline active:scale-95 transition-transform">Yakin?</button>
                                <button wire:click="cancelDelete" class="text-xs font-bold text-slate-400 hover:text-slate-600 active:scale-95 transition">Batal</button>
                            @else
                                <button wire:click="confirmDelete({{ $product->id }})" class="text-xs font-bold text-rose-500 hover:text-rose-600 active:scale-95 transition">Hapus</button>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="7" class="px-6 py-16">
                            <div class="flex flex-col items-center justify-center gap-3 text-center">
                                <div class="w-14 h-14 rounded-2xl bg-sky-50 flex items-center justify-center text-sky-300">
                                    <svg class="w-7 h-7" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"></path></svg>
                                </div>
                                <div>
                                    <p class="text-sm font-bold text-slate-500">Belum ada produk terdaftar</p>
                                    <p class="text-xs text-slate-400 mt-0.5">Produk dari owner atau yang ditambahkan admin akan tampil di sini.</p>
                                </div>
                            </div>
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <div class="pt-2">{{ $products->links() }}</div>

    <!-- Detail Modal -->
    @if ($viewingProduct)
        <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-md flex items-center justify-center z-50 animate-overlay-fade" wire:click.self="closeView">
            <div class="bg-white rounded-3xl shadow-xl border border-slate-50 p-8 animate-modal-pop w-full max-w-lg space-y-6 max-h-[80vh] overflow-y-auto transform scale-100 transition-all duration-300">
                <div class="flex items-center gap-3 border-b border-slate-50 pb-3">
                    <div class="w-10 h-10 rounded-full bg-rose-50 flex items-center justify-center text-rose-500 font-black text-sm">
                        PR
                    </div>
                    <div>
                        <h3 class="font-bold text-lg text-slate-800">{{ $viewingProduct->name }}</h3>
                        <p class="text-xs text-slate-400 font-medium">{{ $viewingProduct->store->store_name ?? '-' }} &middot; {{ $viewingProduct->category->name ?? '-' }}</p>
                    </div>
                </div>

                <div class="flex flex-col gap-1">
                    <span class="text-slate-400 text-xs uppercase font-bold tracking-wider">Deskripsi Produk:</span>
                    <span class="text-slate-700 leading-relaxed text-sm">{{ $viewingProduct->description ?: 'Tidak ada deskripsi.' }}</span>
                </div>

                @if ($viewingProduct->images->isNotEmpty())
                    <div class="space-y-2 border-t border-slate-50 pt-4">
                        <span class="text-slate-400 text-xs uppercase font-bold tracking-wider block">Foto Produk:</span>
                        <div class="flex gap-3 flex-wrap">
                            @foreach ($viewingProduct->images as $image)
                                <img src="{{ $image->image_url }}" alt="Foto {{ $viewingProduct->name }}" class="w-20 h-20 object-cover rounded-xl border border-slate-100 shadow-sm hover:scale-105 transition-transform duration-200">
                            @endforeach
                        </div>
                    </div>
                @endif

                @if ($viewingProduct->variants->isNotEmpty())
                    <div class="space-y-2 border-t border-slate-50 pt-4">
                        <span class="text-slate-400 text-xs uppercase font-bold tracking-wider block">Daftar Varian & Stok:</span>
                        <div class="bg-slate-50 rounded-2xl p-4 border border-slate-100">
                            <table class="w-full text-xs text-left">
                                <thead class="text-slate-400 font-bold border-b border-slate-200 pb-2">
                                    <tr>
                                        <th class="pb-2">Ukuran (Size)</th>
                                        <th class="pb-2">Warna (Color)</th>
                                        <th class="pb-2 text-right">Sisa Stok</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-slate-100/50">
                                    @foreach ($viewingProduct->variants as $variant)
                                        <tr class="text-slate-700 font-semibold">
                                            <td class="py-2.5">{{ $variant->size }}</td>
                                            <td class="py-2.5">{{ $variant->color }}</td>
                                            <td class="py-2.5 text-right font-black text-slate-800">{{ $variant->stock }} pcs</td>
                                        </tr>
                                    @endforeach
                                </tbody>
                            </table>
                        </div>
                    </div>
                @endif

                <div class="flex justify-end pt-2">
                    <button wire:click="closeView" class="w-full px-5 py-3 text-sm font-bold text-slate-500 hover:text-slate-700 bg-slate-50 hover:bg-slate-100 rounded-xl transition-all duration-200">
                        Tutup Detail
                    </button>
                </div>
            </div>
        </div>
    @endif

    <!-- Create Form Modal -->
    @if ($showCreateForm)
        <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-md flex items-center justify-center z-50 animate-overlay-fade" wire:click.self="cancelEdit">
            <div class="bg-white rounded-3xl shadow-xl border border-slate-50 p-8 animate-modal-pop w-full max-w-md space-y-5">
                <h3 class="font-bold text-xl text-slate-800 border-b border-slate-50 pb-3">Tambah Produk Baru</h3>
                
                <div class="space-y-4 max-h-[60vh] overflow-y-auto pr-1">
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Pilih Toko</label>
                        <select wire:model.live="new_store_id" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm bg-white focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                            <option value="">-- Pilih toko --</option>
                            @foreach ($stores as $store)
                                <option value="{{ $store->id }}">{{ $store->store_name }}</option>
                            @endforeach
                        </select>
                        @error('new_store_id') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Kategori (Opsional)</label>
                        <select wire:model="new_category_id" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm bg-white focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                            <option value="">-- Tanpa kategori --</option>
                            @foreach ($categoriesForNewStore as $category)
                                <option value="{{ $category->id }}">{{ $category->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Nama Produk</label>
                        <input type="text" wire:model="name" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                        @error('name') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                    </div>
                    <div class="grid grid-cols-2 gap-3">
                        <div class="space-y-1.5">
                            <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Harga (Rp)</label>
                            <input type="number" wire:model="price" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                            @error('price') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                        </div>
                        <div class="space-y-1.5">
                            <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Stok Awal</label>
                            <input type="number" wire:model="stock" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                            @error('stock') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                        </div>
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Deskripsi Produk</label>
                        <textarea wire:model="description" rows="2" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200"></textarea>
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Status</label>
                        <select wire:model="status" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm bg-white focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                            <option value="active">Aktif</option>
                            <option value="inactive">Nonaktif</option>
                        </select>
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Foto Produk</label>
                        <label class="flex flex-col items-center justify-center gap-1.5 border-2 border-dashed border-slate-200 rounded-xl px-4 py-5 text-center cursor-pointer hover:border-rose-300 hover:bg-rose-50/30 transition-all duration-200">
                            <svg class="w-6 h-6 text-slate-300" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                            <span class="text-xs font-bold text-slate-500">Klik untuk pilih gambar (bisa lebih dari satu)</span>
                            <input type="file" wire:model="newImages" multiple accept="image/*" class="hidden">
                        </label>
                        @error('newImages.*') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror

                        <div wire:loading wire:target="newImages" class="text-xs font-bold text-slate-400 flex items-center gap-1.5 pt-1">
                            <svg class="w-3.5 h-3.5 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z"></path></svg>
                            Mengunggah pratinjau...
                        </div>

                        @if (!empty($newImages))
                            <div class="flex gap-2 flex-wrap pt-1">
                                @foreach ($newImages as $index => $image)
                                    <div class="relative group">
                                        <img src="{{ $image->temporaryUrl() }}" class="w-16 h-16 object-cover rounded-lg border border-slate-200">
                                        <button type="button" wire:click="removeNewImage({{ $index }})"
                                            class="absolute -top-1.5 -right-1.5 w-5 h-5 rounded-full bg-rose-500 text-white text-xs flex items-center justify-center shadow-sm hover:bg-rose-600 active:scale-90 transition">&times;</button>
                                        @if ($index === 0)
                                            <span class="absolute bottom-0 inset-x-0 bg-slate-900/60 text-white text-[9px] font-bold text-center rounded-b-lg py-0.5">Utama</span>
                                        @endif
                                    </div>
                                @endforeach
                            </div>
                        @endif
                    </div>
                    <div class="bg-rose-50/50 border border-rose-100 rounded-xl p-3 text-[11px] text-rose-600 font-medium leading-relaxed">
                        Catatan: Varian ukuran/warna belum bisa ditambah dari sini. Lengkapi melalui aplikasi mobile Seller Ootday.
                    </div>
                </div>

                <div class="flex justify-end gap-3 pt-3 border-t border-slate-50">
                    <button wire:click="cancelEdit" class="px-5 py-3 text-sm font-bold text-slate-500 hover:text-slate-700 bg-slate-50 hover:bg-slate-100 rounded-xl transition-all duration-200">
                        Batal
                    </button>
                    <button wire:click="saveNew" wire:loading.attr="disabled" wire:target="saveNew" class="px-6 py-3 text-sm font-bold bg-gradient-to-r from-rose-500 to-pink-500 hover:from-rose-600 hover:to-pink-600 disabled:opacity-70 disabled:cursor-not-allowed text-white rounded-xl shadow-md shadow-rose-500/15 hover:shadow-lg transition-all duration-200">
                        <span wire:loading.remove wire:target="saveNew">Simpan</span>
                        <span wire:loading wire:target="saveNew" class="inline-flex items-center gap-1.5"><svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z"></path></svg>Menyimpan...</span>
                    </button>
                </div>
            </div>
        </div>
    @endif

    <!-- Edit Form Modal -->
    @if ($editingId)
        <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-md flex items-center justify-center z-50 animate-overlay-fade" wire:click.self="cancelEdit">
            <div class="bg-white rounded-3xl shadow-xl border border-slate-50 p-8 animate-modal-pop w-full max-w-md space-y-5">
                <h3 class="font-bold text-xl text-slate-800 border-b border-slate-50 pb-3">Edit Detail Produk</h3>
                
                <div class="space-y-4 max-h-[60vh] overflow-y-auto pr-1">
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Nama Produk</label>
                        <input type="text" wire:model="name" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                        @error('name') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                    </div>
                    <div class="grid grid-cols-2 gap-3">
                        <div class="space-y-1.5">
                            <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Harga (Rp)</label>
                            <input type="number" wire:model="price" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                            @error('price') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                        </div>
                        <div class="space-y-1.5">
                            <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Stok Utama</label>
                            <input type="number" wire:model="stock" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                            @error('stock') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                        </div>
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Status</label>
                        <select wire:model="status" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm bg-white focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                            <option value="active">Aktif</option>
                            <option value="inactive">Nonaktif</option>
                        </select>
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Tambah Foto Produk</label>
                        <label class="flex flex-col items-center justify-center gap-1.5 border-2 border-dashed border-slate-200 rounded-xl px-4 py-5 text-center cursor-pointer hover:border-rose-300 hover:bg-rose-50/30 transition-all duration-200">
                            <svg class="w-6 h-6 text-slate-300" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                            <span class="text-xs font-bold text-slate-500">Klik untuk tambah gambar baru</span>
                            <input type="file" wire:model="editImages" multiple accept="image/*" class="hidden">
                        </label>
                        @error('editImages.*') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror

                        <div wire:loading wire:target="editImages" class="text-xs font-bold text-slate-400 flex items-center gap-1.5 pt-1">
                            <svg class="w-3.5 h-3.5 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z"></path></svg>
                            Mengunggah pratinjau...
                        </div>

                        @if (!empty($editImages))
                            <div class="flex gap-2 flex-wrap pt-1">
                                @foreach ($editImages as $index => $image)
                                    <div class="relative group">
                                        <img src="{{ $image->temporaryUrl() }}" class="w-16 h-16 object-cover rounded-lg border border-slate-200">
                                        <button type="button" wire:click="removeEditImage({{ $index }})"
                                            class="absolute -top-1.5 -right-1.5 w-5 h-5 rounded-full bg-rose-500 text-white text-xs flex items-center justify-center shadow-sm hover:bg-rose-600 active:scale-90 transition">&times;</button>
                                    </div>
                                @endforeach
                            </div>
                        @endif
                        <p class="text-[11px] text-slate-400 font-medium">Gambar yang sudah ada bisa dilihat lewat tombol "Detail". Foto baru akan ditambahkan, bukan menggantikan.</p>
                    </div>
                </div>

                <div class="flex justify-end gap-3 pt-3 border-t border-slate-50">
                    <button wire:click="cancelEdit" class="px-5 py-3 text-sm font-bold text-slate-500 hover:text-slate-700 bg-slate-50 hover:bg-slate-100 rounded-xl transition-all duration-200">
                        Batal
                    </button>
                    <button wire:click="save" wire:loading.attr="disabled" wire:target="save" class="px-6 py-3 text-sm font-bold bg-gradient-to-r from-rose-500 to-pink-500 hover:from-rose-600 hover:to-pink-600 disabled:opacity-70 disabled:cursor-not-allowed text-white rounded-xl shadow-md shadow-rose-500/15 hover:shadow-lg transition-all duration-200">
                        <span wire:loading.remove wire:target="save">Simpan</span>
                        <span wire:loading wire:target="save" class="inline-flex items-center gap-1.5"><svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z"></path></svg>Menyimpan...</span>
                    </button>
                </div>
            </div>
        </div>
    @endif
</div>
