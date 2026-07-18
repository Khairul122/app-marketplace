<div class="space-y-6">
    @if (session('success'))
        <div class="hidden alert-flash-data" data-id="success-{{ session('success') }}-{{ uniqid() }}" data-type="success" data-message="{{ session('success') }}"></div>
    @endif
    @if ($errors->any())
        <div class="hidden alert-flash-data" data-id="error-{{ $errors->first() }}-{{ uniqid() }}" data-type="error" data-message="{{ $errors->first() }}"></div>
    @endif

    <!-- Toolbar Filters -->
    <div class="flex justify-between items-center bg-white p-4 rounded-2xl border border-slate-100 shadow-sm">
        <span class="text-sm text-slate-500 font-medium">Layanan ekspedisi pengiriman paket pelanggan</span>
        <button wire:click="create" class="px-5 py-2.5 text-sm font-bold bg-gradient-to-r from-rose-500 to-pink-500 hover:from-rose-600 hover:to-pink-600 text-white rounded-xl shadow-md shadow-rose-500/15 hover:shadow-lg hover:scale-[1.02] active:scale-[0.98] transition-all duration-200 whitespace-nowrap">
            + Tambah Layanan
        </button>
    </div>

    <!-- Table List -->
    <div class="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
        <table class="w-full text-sm text-left">
            <thead class="bg-slate-50/75 border-b border-slate-100 text-slate-400 text-xs font-bold uppercase tracking-wider">
                <tr>
                    <th class="px-6 py-4">Nama Layanan</th>
                    <th class="px-6 py-4">Biaya Ongkir Dasar</th>
                    <th class="px-6 py-4">Status Aktif</th>
                    <th class="px-6 py-4"></th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                @forelse ($methods as $method)
                    <tr class="hover:bg-slate-50/50 transition-colors">
                        <td class="px-6 py-4 font-bold text-slate-800 flex items-center gap-3">
                            <div class="w-8 h-8 rounded-full bg-violet-50 flex items-center justify-center font-bold text-violet-500 text-xs">
                                {{ strtoupper(substr($method->name, 0, 2)) }}
                            </div>
                            <span>{{ $method->name }}</span>
                        </td>
                        <td class="px-6 py-4 text-slate-800 font-extrabold tabular-nums">Rp {{ number_format($method->base_cost, 0, ',', '.') }}</td>
                        <td class="px-6 py-4">
                            <button wire:click="toggleActive({{ $method->id }})"
                                class="px-3 py-1 rounded-full text-xs font-bold border transition-colors {{ $method->is_active ? 'bg-green-50 text-green-600 border-green-100/50 hover:bg-green-100/30' : 'bg-slate-100 text-slate-500 hover:bg-slate-200' }}">
                                {{ $method->is_active ? 'Aktif (Klik ubah)' : 'Nonaktif (Klik ubah)' }}
                            </button>
                        </td>
                        <td class="px-6 py-4 text-right space-x-3 whitespace-nowrap">
                            <button wire:click="edit({{ $method->id }})" class="text-xs font-bold text-slate-600 hover:text-rose-500 active:scale-95 transition">Edit</button>
                            @if ($confirmingDeleteId === $method->id)
                                <button wire:click="delete({{ $method->id }})" class="text-xs font-black text-rose-600 hover:underline active:scale-95 transition-transform">Yakin?</button>
                                <button wire:click="cancelDelete" class="text-xs font-bold text-slate-400 hover:text-slate-600 active:scale-95 transition">Batal</button>
                            @else
                                <button wire:click="confirmDelete({{ $method->id }})" class="text-xs font-bold text-rose-500 hover:text-rose-600 active:scale-95 transition">Hapus</button>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" class="px-6 py-16">
                            <div class="flex flex-col items-center justify-center gap-3 text-center">
                                <div class="w-14 h-14 rounded-2xl bg-emerald-50 flex items-center justify-center text-emerald-300">
                                    <svg class="w-7 h-7" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 17a2 2 0 11-4 0 2 2 0 014 0zM19 17a2 2 0 11-4 0 2 2 0 014 0zM13 16V6a1 1 0 00-1-1H4a1 1 0 00-1 1v10M13 16h6a1 1 0 001-1v-4a1 1 0 00-1-1h-2m-3-7h3m-3 4h3"></path></svg>
                                </div>
                                <div>
                                    <p class="text-sm font-bold text-slate-500">Belum ada layanan pengiriman</p>
                                    <p class="text-xs text-slate-400 mt-0.5">Tambahkan ekspedisi agar pelanggan bisa memilih pengiriman.</p>
                                </div>
                            </div>
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Create Form Modal -->
    @if ($showForm)
        <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-md flex items-center justify-center z-50 animate-overlay-fade" wire:click.self="cancel">
            <div class="bg-white rounded-3xl shadow-xl border border-slate-50 p-8 animate-modal-pop w-full max-w-md space-y-5">
                <h3 class="font-bold text-xl text-slate-800 border-b border-slate-50 pb-3">
                    {{ $editingId ? 'Edit' : 'Tambah' }} Metode Pengiriman
                </h3>
                
                <div class="space-y-4">
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Nama Ekspedisi</label>
                        <input type="text" wire:model="name" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                        @error('name') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Biaya Ongkir Dasar (Rp)</label>
                        <input type="number" wire:model="base_cost" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                        @error('base_cost') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                    </div>
                    <div class="flex items-center gap-2 pt-2">
                        <input type="checkbox" wire:model="is_active" id="isActiveCheck" class="rounded border-slate-300 text-rose-500 focus:ring-rose-500/20 w-4 h-4">
                        <label for="isActiveCheck" class="text-sm font-bold text-slate-600 select-none">Aktifkan Layanan Pengiriman</label>
                    </div>
                </div>

                <div class="flex justify-end gap-3 pt-3 border-t border-slate-50">
                    <button wire:click="cancel" class="px-5 py-3 text-sm font-bold text-slate-500 hover:text-slate-700 bg-slate-50 hover:bg-slate-100 rounded-xl transition-all duration-200">
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
