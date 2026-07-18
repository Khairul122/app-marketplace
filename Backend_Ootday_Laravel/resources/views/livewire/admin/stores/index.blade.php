<div class="space-y-6">
    @if (session('success'))
        <div class="hidden alert-flash-data" data-id="success-{{ session('success') }}-{{ uniqid() }}" data-type="success" data-message="{{ session('success') }}"></div>
    @endif
    @if ($errors->any())
        <div class="hidden alert-flash-data" data-id="error-{{ $errors->first() }}-{{ uniqid() }}" data-type="error" data-message="{{ $errors->first() }}"></div>
    @endif

    <!-- Toolbar Filters -->
    <div class="flex flex-col sm:flex-row gap-4 justify-between items-start sm:items-center bg-white p-4 rounded-2xl border border-slate-100 shadow-sm">
        <input type="text" wire:model.live.debounce.300ms="search" placeholder="Cari nama toko..."
            class="rounded-xl border border-slate-200 px-4 py-2.5 text-sm bg-slate-50/50 focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200 w-full sm:max-w-sm">
        <button wire:click="create" class="px-5 py-2.5 text-sm font-bold bg-gradient-to-r from-rose-500 to-pink-500 hover:from-rose-600 hover:to-pink-600 text-white rounded-xl shadow-md shadow-rose-500/15 hover:shadow-lg hover:scale-[1.02] active:scale-[0.98] transition-all duration-200 whitespace-nowrap">
            + Tambah Toko
        </button>
    </div>

    <!-- Table List -->
    <div class="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
        <table class="w-full text-sm text-left">
            <thead class="bg-slate-50/75 border-b border-slate-100 text-slate-400 text-xs font-bold uppercase tracking-wider">
                <tr>
                    <th class="px-6 py-4">Nama Toko</th>
                    <th class="px-6 py-4">Pemilik</th>
                    <th class="px-6 py-4 text-center">Jumlah Produk</th>
                    <th class="px-6 py-4">Status</th>
                    <th class="px-6 py-4"></th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                @forelse ($stores as $store)
                    <tr class="hover:bg-slate-50/50 transition-colors">
                        <td class="px-6 py-4 font-bold text-slate-800 flex items-center gap-3">
                            <div class="w-8 h-8 rounded-full bg-amber-50 flex items-center justify-center font-bold text-amber-500 text-xs">
                                {{ strtoupper(substr($store->store_name, 0, 2)) }}
                            </div>
                            <span>{{ $store->store_name }}</span>
                        </td>
                        <td class="px-6 py-4 text-slate-600 font-medium">{{ $store->owner->name ?? '-' }}</td>
                        <td class="px-6 py-4 text-center">
                            <span class="px-2.5 py-1 rounded-full text-xs font-bold bg-slate-100 text-slate-600">
                                {{ $store->products_count }} produk
                            </span>
                        </td>
                        <td class="px-6 py-4">
                            <span class="px-2.5 py-1 rounded-full text-xs font-bold {{ $store->status === 'active' ? 'bg-green-50 text-green-600 border border-green-100/50' : 'bg-slate-100 text-slate-500' }}">
                                {{ $store->status === 'active' ? 'Aktif' : 'Nonaktif' }}
                            </span>
                        </td>
                        <td class="px-6 py-4 text-right space-x-3 whitespace-nowrap">
                            <button wire:click="view({{ $store->id }})" class="text-xs font-bold text-slate-400 hover:text-rose-500 active:scale-95 transition">Lihat</button>
                            <button wire:click="edit({{ $store->id }})" class="text-xs font-bold text-slate-600 hover:text-rose-500 active:scale-95 transition">Edit</button>
                            @if ($confirmingDeleteId === $store->id)
                                <button wire:click="delete({{ $store->id }})" class="text-xs font-black text-rose-600 hover:underline active:scale-95 transition-transform">Yakin?</button>
                                <button wire:click="cancelDelete" class="text-xs font-bold text-slate-400 hover:text-slate-600 active:scale-95 transition">Batal</button>
                            @else
                                <button wire:click="confirmDelete({{ $store->id }})" class="text-xs font-bold text-rose-500 hover:text-rose-600 active:scale-95 transition">Hapus</button>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5" class="px-6 py-16">
                            <div class="flex flex-col items-center justify-center gap-3 text-center">
                                <div class="w-14 h-14 rounded-2xl bg-amber-50 flex items-center justify-center text-amber-300">
                                    <svg class="w-7 h-7" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path></svg>
                                </div>
                                <div>
                                    <p class="text-sm font-bold text-slate-500">Belum ada toko terdaftar</p>
                                    <p class="text-xs text-slate-400 mt-0.5">Toko akan muncul setelah owner mendaftar, atau tambahkan manual.</p>
                                </div>
                            </div>
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <div class="pt-2">{{ $stores->links() }}</div>

    <!-- Detail Modal -->
    @if ($viewingStore)
        <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-md flex items-center justify-center z-50 animate-overlay-fade" wire:click.self="closeView">
            <div class="bg-white rounded-3xl shadow-xl border border-slate-50 p-8 animate-modal-pop w-full max-w-lg space-y-5 transform scale-100 transition-all duration-300">
                <div class="flex items-center gap-3 border-b border-slate-50 pb-3">
                    <div class="w-10 h-10 rounded-full bg-amber-50 flex items-center justify-center text-amber-500 font-black text-sm">
                        {{ strtoupper(substr($viewingStore->store_name, 0, 2)) }}
                    </div>
                    <div>
                        <h3 class="font-bold text-lg text-slate-800">{{ $viewingStore->store_name }}</h3>
                        <p class="text-xs text-slate-400 font-medium">Informasi Profil Toko</p>
                    </div>
                </div>
                
                <div class="space-y-3.5 text-sm text-slate-600 font-medium">
                    <div class="flex justify-between">
                        <span class="text-slate-400">Pemilik:</span>
                        <span class="text-slate-800 font-bold">{{ $viewingStore->owner->name ?? '-' }} ({{ $viewingStore->owner->email ?? '-' }})</span>
                    </div>
                    <div class="flex flex-col gap-1 border-t border-slate-50 pt-3">
                        <span class="text-slate-400 text-xs uppercase font-bold tracking-wider">Deskripsi Toko:</span>
                        <span class="text-slate-700 leading-relaxed text-sm">{{ $viewingStore->description ?: 'Tidak ada deskripsi.' }}</span>
                    </div>
                    <div class="flex flex-col gap-1 border-t border-slate-50 pt-3">
                        <span class="text-slate-400 text-xs uppercase font-bold tracking-wider">Alamat Toko:</span>
                        <span class="text-slate-700 leading-relaxed text-sm">{{ $viewingStore->address ?: 'Tidak ada alamat.' }}</span>
                    </div>
                    <div class="flex justify-between border-t border-slate-50 pt-3">
                        <span class="text-slate-400">Total Kategori & Produk:</span>
                        <span class="text-slate-800 font-bold">{{ $viewingStore->categories->count() }} kategori &middot; {{ $viewingStore->products_count }} produk</span>
                    </div>
                </div>
                
                <div class="flex justify-end pt-2">
                    <button wire:click="closeView" class="w-full px-5 py-3 text-sm font-bold text-slate-500 hover:text-slate-700 bg-slate-50 hover:bg-slate-100 rounded-xl transition-all duration-200">
                        Tutup
                    </button>
                </div>
            </div>
        </div>
    @endif

    <!-- Create Form Modal -->
    @if ($showCreateForm)
        <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-md flex items-center justify-center z-50 animate-overlay-fade" wire:click.self="cancelEdit">
            <div class="bg-white rounded-3xl shadow-xl border border-slate-50 p-8 animate-modal-pop w-full max-w-md space-y-5">
                <h3 class="font-bold text-xl text-slate-800 border-b border-slate-50 pb-3">Tambah Toko Baru</h3>
                
                <div class="space-y-4 max-h-[60vh] overflow-y-auto pr-1">
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Pemilik (Penjual tanpa toko)</label>
                        <select wire:model="owner_id" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm bg-white focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                            <option value="">-- Pilih owner --</option>
                            @foreach ($availableOwners as $owner)
                                <option value="{{ $owner->id }}">{{ $owner->name }} ({{ $owner->email }})</option>
                            @endforeach
                        </select>
                        @error('owner_id') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Nama Toko</label>
                        <input type="text" wire:model="store_name" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                        @error('store_name') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Deskripsi</label>
                        <textarea wire:model="description" rows="2" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200"></textarea>
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Alamat</label>
                        <textarea wire:model="address" rows="2" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200"></textarea>
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Status</label>
                        <select wire:model="status" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm bg-white focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                            <option value="active">Aktif</option>
                            <option value="inactive">Nonaktif</option>
                        </select>
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
                <h3 class="font-bold text-xl text-slate-800 border-b border-slate-50 pb-3">Edit Detail Toko</h3>
                
                <div class="space-y-4 max-h-[60vh] overflow-y-auto pr-1">
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Nama Toko</label>
                        <input type="text" wire:model="store_name" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                        @error('store_name') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Deskripsi</label>
                        <textarea wire:model="description" rows="2" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200"></textarea>
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Alamat</label>
                        <textarea wire:model="address" rows="2" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200"></textarea>
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Status</label>
                        <select wire:model="status" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm bg-white focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                            <option value="active">Aktif</option>
                            <option value="inactive">Nonaktif</option>
                        </select>
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
