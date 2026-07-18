<div class="space-y-6">
    @if (session('success'))
        <div class="hidden alert-flash-data" data-id="success-{{ session('success') }}-{{ uniqid() }}" data-type="success" data-message="{{ session('success') }}"></div>
    @endif
    @if ($errors->any())
        <div class="hidden alert-flash-data" data-id="error-{{ $errors->first() }}-{{ uniqid() }}" data-type="error" data-message="{{ $errors->first() }}"></div>
    @endif

    <!-- Toolbar Filters -->
    <div class="flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center bg-white p-4 rounded-2xl border border-slate-100 shadow-sm">
        <select wire:model.live="storeFilter" class="rounded-xl border border-slate-200 px-4 py-2.5 text-sm bg-white focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200 min-w-[200px]">
            <option value="">Semua Toko</option>
            @foreach ($stores as $store)
                <option value="{{ $store->id }}">{{ $store->store_name }}</option>
            @endforeach
        </select>
        <button wire:click="create" class="px-5 py-2.5 text-sm font-bold bg-gradient-to-r from-rose-500 to-pink-500 hover:from-rose-600 hover:to-pink-600 text-white rounded-xl shadow-md shadow-rose-500/15 hover:shadow-lg hover:scale-[1.02] active:scale-[0.98] transition-all duration-200 whitespace-nowrap">
            + Tambah Kategori
        </button>
    </div>

    <!-- Table List -->
    <div class="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
        <table class="w-full text-sm text-left">
            <thead class="bg-slate-50/75 border-b border-slate-100 text-slate-400 text-xs font-bold uppercase tracking-wider">
                <tr>
                    <th class="px-6 py-4">Nama Kategori</th>
                    <th class="px-6 py-4">Toko Pengelola</th>
                    <th class="px-6 py-4 text-center">Jumlah Produk</th>
                    <th class="px-6 py-4"></th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                @forelse ($categories as $category)
                    <tr class="hover:bg-slate-50/50 transition-colors">
                        <td class="px-6 py-4 font-bold text-slate-800 flex items-center gap-3">
                            <div class="w-8 h-8 rounded-full bg-rose-50 flex items-center justify-center font-bold text-rose-500 text-xs">
                                {{ strtoupper(substr($category->name, 0, 2)) }}
                            </div>
                            <span>{{ $category->name }}</span>
                        </td>
                        <td class="px-6 py-4 text-slate-600 font-medium">{{ $category->store->store_name ?? '-' }}</td>
                        <td class="px-6 py-4 text-center">
                            <span class="px-2.5 py-1 rounded-full text-xs font-bold bg-slate-100 text-slate-600">
                                {{ $category->products_count }} produk
                            </span>
                        </td>
                        <td class="px-6 py-4 text-right space-x-3 whitespace-nowrap">
                            <button wire:click="view({{ $category->id }})" class="text-xs font-bold text-slate-400 hover:text-rose-500 active:scale-95 transition">Lihat</button>
                            <button wire:click="edit({{ $category->id }})" class="text-xs font-bold text-slate-600 hover:text-rose-500 active:scale-95 transition">Edit</button>
                            @if ($confirmingDeleteId === $category->id)
                                <button wire:click="delete({{ $category->id }})" class="text-xs font-black text-rose-600 hover:underline active:scale-95 transition-transform">Yakin?</button>
                                <button wire:click="cancelDelete" class="text-xs font-bold text-slate-400 hover:text-slate-600 active:scale-95 transition">Batal</button>
                            @else
                                <button wire:click="confirmDelete({{ $category->id }})" class="text-xs font-bold text-rose-500 hover:text-rose-600 active:scale-95 transition">Hapus</button>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" class="px-6 py-16">
                            <div class="flex flex-col items-center justify-center gap-3 text-center">
                                <div class="w-14 h-14 rounded-2xl bg-rose-50 flex items-center justify-center text-rose-300">
                                    <svg class="w-7 h-7" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h7"></path></svg>
                                </div>
                                <div>
                                    <p class="text-sm font-bold text-slate-500">Belum ada kategori terdaftar</p>
                                    <p class="text-xs text-slate-400 mt-0.5">Tambahkan kategori pertama untuk mulai mengelompokkan produk.</p>
                                </div>
                            </div>
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <div class="pt-2">{{ $categories->links() }}</div>

    <!-- Detail Modal -->
    @if ($viewingCategory)
        <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-md flex items-center justify-center z-50 animate-overlay-fade" wire:click.self="closeView">
            <div class="bg-white rounded-3xl shadow-xl border border-slate-50 p-8 animate-modal-pop w-full max-w-md space-y-5 transform scale-100 transition-all duration-300">
                <div class="flex items-center gap-3 border-b border-slate-50 pb-3">
                    <div class="w-10 h-10 rounded-full bg-rose-50 flex items-center justify-center text-rose-500 font-black text-sm">
                        {{ strtoupper(substr($viewingCategory->name, 0, 2)) }}
                    </div>
                    <div>
                        <h3 class="font-bold text-lg text-slate-800">{{ $viewingCategory->name }}</h3>
                        <p class="text-xs text-slate-400 font-medium">Detail informasi kategori</p>
                    </div>
                </div>
                
                <div class="space-y-3 text-sm text-slate-600 font-medium">
                    <div class="flex justify-between">
                        <span class="text-slate-400">Toko:</span>
                        <span class="text-slate-800 font-bold">{{ $viewingCategory->store->store_name ?? '-' }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-slate-400">Total Produk:</span>
                        <span class="text-slate-800 font-bold">{{ $viewingCategory->products_count }} produk</span>
                    </div>
                </div>

                @if ($viewingCategory->products->isNotEmpty())
                    <div class="space-y-2 pt-2 border-t border-slate-50">
                        <h4 class="text-xs font-bold text-slate-400 uppercase tracking-wider">Daftar Produk Terkait:</h4>
                        <ul class="text-xs text-slate-600 list-disc pl-5 space-y-1 max-h-[150px] overflow-y-auto">
                            @foreach ($viewingCategory->products->take(10) as $product)
                                <li class="font-medium text-slate-700">{{ $product->name }}</li>
                            @endforeach
                        </ul>
                    </div>
                @endif
                
                <div class="flex justify-end pt-2">
                    <button wire:click="closeView" class="w-full px-5 py-3 text-sm font-bold text-slate-500 hover:text-slate-700 bg-slate-50 hover:bg-slate-100 rounded-xl transition-all duration-200">
                        Tutup
                    </button>
                </div>
            </div>
        </div>
    @endif

    <!-- Create/Edit Form Modal -->
    @if ($showCreateForm || $editingId)
        <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-md flex items-center justify-center z-50 animate-overlay-fade" wire:click.self="cancelEdit">
            <div class="bg-white rounded-3xl shadow-xl border border-slate-50 p-8 animate-modal-pop w-full max-w-md space-y-5">
                <h3 class="font-bold text-xl text-slate-800 border-b border-slate-50 pb-3">
                    {{ $editingId ? 'Edit Kategori' : 'Tambah Kategori' }}
                </h3>
                
                <div class="space-y-4">
                    @if (!$editingId)
                        <div class="space-y-1.5">
                            <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Toko Pengelola</label>
                            <select wire:model="store_id" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm bg-white focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                                <option value="">-- Pilih toko --</option>
                                @foreach ($stores as $store)
                                    <option value="{{ $store->id }}">{{ $store->store_name }}</option>
                                @endforeach
                            </select>
                            @error('store_id') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                        </div>
                    @endif
                    
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Nama Kategori</label>
                        <input type="text" wire:model="name" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                        @error('name') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                    </div>
                    
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Icon URL</label>
                        <input type="text" wire:model="icon_url" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                    </div>
                </div>

                <div class="flex justify-end gap-3 pt-3 border-t border-slate-50">
                    <button wire:click="cancelEdit" class="px-5 py-3 text-sm font-bold text-slate-500 hover:text-slate-700 bg-slate-50 hover:bg-slate-100 rounded-xl transition-all duration-200">
                        Batal
                    </button>
                    <button wire:click="{{ $editingId ? 'save' : 'saveNew' }}" wire:loading.attr="disabled" wire:target="save,saveNew" class="px-6 py-3 text-sm font-bold bg-gradient-to-r from-rose-500 to-pink-500 hover:from-rose-600 hover:to-pink-600 disabled:opacity-70 disabled:cursor-not-allowed text-white rounded-xl shadow-md shadow-rose-500/15 hover:shadow-lg transition-all duration-200">
                        <span wire:loading.remove wire:target="save,saveNew">Simpan</span>
                        <span wire:loading wire:target="save,saveNew" class="inline-flex items-center gap-1.5"><svg class="w-4 h-4 animate-spin" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8z"></path></svg>Menyimpan...</span>
                    </button>
                </div>
            </div>
        </div>
    @endif
</div>
