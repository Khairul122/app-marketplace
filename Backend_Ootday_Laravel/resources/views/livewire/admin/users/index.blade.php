<div class="space-y-6">
    @if (session('success'))
        <div class="hidden alert-flash-data" data-id="success-{{ session('success') }}-{{ uniqid() }}" data-type="success" data-message="{{ session('success') }}"></div>
    @endif
    @if ($errors->any())
        <div class="hidden alert-flash-data" data-id="error-{{ $errors->first() }}-{{ uniqid() }}" data-type="error" data-message="{{ $errors->first() }}"></div>
    @endif

    <!-- Toolbar Filters -->
    <div class="flex flex-col md:flex-row gap-4 justify-between items-start md:items-center bg-white p-4 rounded-2xl border border-slate-100 shadow-sm">
        <div class="flex flex-col sm:flex-row gap-3 w-full md:w-auto">
            <input type="text" wire:model.live.debounce.300ms="search" placeholder="Cari nama/email..."
                class="rounded-xl border border-slate-200 px-4 py-2.5 text-sm bg-slate-50/50 focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200 min-w-[240px]">
            <select wire:model.live="roleFilter" class="rounded-xl border border-slate-200 px-4 py-2.5 text-sm bg-white focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200 min-w-[160px]">
                <option value="">Semua Role</option>
                <option value="pelanggan">Pembeli</option>
                <option value="owner">Penjual</option>
                <option value="admin">Admin</option>
            </select>
        </div>
        <button wire:click="create" class="px-5 py-2.5 text-sm font-bold bg-gradient-to-r from-rose-500 to-pink-500 hover:from-rose-600 hover:to-pink-600 text-white rounded-xl shadow-md shadow-rose-500/15 hover:shadow-lg hover:scale-[1.02] active:scale-[0.98] transition-all duration-200 whitespace-nowrap">
            + Tambah User
        </button>
    </div>

    <!-- Table List -->
    <div class="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
        <table class="w-full text-sm text-left">
            <thead class="bg-slate-50/75 border-b border-slate-100 text-slate-400 text-xs font-bold uppercase tracking-wider">
                <tr>
                    <th class="px-6 py-4">Nama</th>
                    <th class="px-6 py-4">Email</th>
                    <th class="px-6 py-4">Role</th>
                    <th class="px-6 py-4">Toko</th>
                    <th class="px-6 py-4">Terdaftar</th>
                    <th class="px-6 py-4"></th>
                </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
                @forelse ($users as $user)
                    <tr class="hover:bg-slate-50/50 transition-colors">
                        <td class="px-6 py-4 font-bold text-slate-800 flex items-center gap-3">
                            @php
                                $avatarColor = match($user->role) {
                                    'admin' => 'bg-violet-50 text-violet-500',
                                    'owner' => 'bg-rose-50 text-rose-500',
                                    default => 'bg-emerald-50 text-emerald-500',
                                };
                            @endphp
                            <div class="w-8 h-8 rounded-full {{ $avatarColor }} flex items-center justify-center font-bold text-xs uppercase">
                                {{ substr($user->name, 0, 2) }}
                            </div>
                            <span>{{ $user->name }}</span>
                        </td>
                        <td class="px-6 py-4 text-slate-600 font-medium">{{ $user->email }}</td>
                        <td class="px-6 py-4">
                            @php
                                $roleBadge = match($user->role) {
                                    'admin' => 'bg-violet-50 text-violet-600 border border-violet-100/50',
                                    'owner' => 'bg-rose-50 text-rose-600 border border-rose-100/50',
                                    default => 'bg-emerald-50 text-emerald-600 border border-emerald-100/50',
                                };
                                $roleLabel = match($user->role) {
                                    'admin' => 'Admin',
                                    'owner' => 'Penjual',
                                    default => 'Pembeli',
                                };
                            @endphp
                            <span class="px-2.5 py-1 rounded-full text-xs font-bold {{ $roleBadge }}">{{ $roleLabel }}</span>
                        </td>
                        <td class="px-6 py-4 text-slate-600 font-medium">{{ $user->store->store_name ?? '-' }}</td>
                        <td class="px-6 py-4 text-slate-500 font-medium">{{ $user->created_at->format('d M Y') }}</td>
                        <td class="px-6 py-4 text-right space-x-3 whitespace-nowrap">
                            <button wire:click="view({{ $user->id }})" class="text-xs font-bold text-slate-400 hover:text-rose-500 active:scale-95 transition">Lihat</button>
                            @if ($confirmingDeleteId === $user->id)
                                <button wire:click="delete({{ $user->id }})" class="text-xs font-black text-rose-600 hover:underline active:scale-95 transition-transform">Yakin?</button>
                                <button wire:click="cancelDelete" class="text-xs font-bold text-slate-400 hover:text-slate-600 active:scale-95 transition">Batal</button>
                            @else
                                <button wire:click="confirmDelete({{ $user->id }})" class="text-xs font-bold text-rose-500 hover:text-rose-600 active:scale-95 transition">Hapus</button>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" class="px-6 py-16">
                            <div class="flex flex-col items-center justify-center gap-3 text-center">
                                <div class="w-14 h-14 rounded-2xl bg-violet-50 flex items-center justify-center text-violet-300">
                                    <svg class="w-7 h-7" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"></path></svg>
                                </div>
                                <div>
                                    <p class="text-sm font-bold text-slate-500">Tidak ada user ditemukan</p>
                                    <p class="text-xs text-slate-400 mt-0.5">Coba ubah kata kunci pencarian atau filter role.</p>
                                </div>
                            </div>
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <div class="pt-2">{{ $users->links() }}</div>

    <!-- Detail Modal -->
    @if ($viewingUser)
        <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-md flex items-center justify-center z-50 animate-overlay-fade" wire:click.self="closeView">
            <div class="bg-white rounded-3xl shadow-xl border border-slate-50 p-8 animate-modal-pop w-full max-w-md space-y-5 transform scale-100 transition-all duration-300">
                <div class="flex items-center gap-3 border-b border-slate-50 pb-3">
                    <div class="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center font-bold text-slate-500 text-sm">
                        {{ strtoupper(substr($viewingUser->name, 0, 2)) }}
                    </div>
                    <div>
                        <h3 class="font-bold text-lg text-slate-800">{{ $viewingUser->name }}</h3>
                        <p class="text-xs text-slate-400 font-medium">Detail Akun & Aktivitas</p>
                    </div>
                </div>
                
                <div class="space-y-3.5 text-sm text-slate-600 font-medium">
                    <div class="flex justify-between">
                        <span class="text-slate-400">Email:</span>
                        <span class="text-slate-800 font-bold">{{ $viewingUser->email }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-slate-400">No. HP:</span>
                        <span class="text-slate-800 font-bold">{{ $viewingUser->phone ?: '-' }}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-slate-400">Role:</span>
                        <span class="px-2 py-0.5 rounded-full text-xs font-bold {{ $roleBadge }}">{{ $roleLabel }}</span>
                    </div>
                    @if ($viewingUser->store)
                        <div class="flex justify-between">
                            <span class="text-slate-400">Toko:</span>
                            <span class="text-slate-800 font-bold">{{ $viewingUser->store->store_name }} ({{ $viewingUser->store->status }})</span>
                        </div>
                    @endif
                    <div class="flex justify-between">
                        <span class="text-slate-400">Jumlah Alamat:</span>
                        <span class="text-slate-800 font-bold">{{ $viewingUser->addresses->count() }} alamat</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-slate-400">Jumlah Pesanan:</span>
                        <span class="text-slate-800 font-bold">{{ $viewingUser->orders->count() }} transaksi</span>
                    </div>
                    <div class="flex justify-between pt-2 border-t border-slate-50">
                        <span class="text-slate-400">Tanggal Terdaftar:</span>
                        <span class="text-slate-500 text-xs">{{ $viewingUser->created_at->format('d M Y H:i') }}</span>
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
    @if ($showForm)
        <div class="fixed inset-0 bg-slate-900/40 backdrop-blur-md flex items-center justify-center z-50 animate-overlay-fade" wire:click.self="cancelForm">
            <div class="bg-white rounded-3xl shadow-xl border border-slate-50 p-8 animate-modal-pop w-full max-w-md space-y-5">
                <h3 class="font-bold text-xl text-slate-800 border-b border-slate-50 pb-3">Tambah User Baru</h3>
                
                <div class="space-y-4 max-h-[60vh] overflow-y-auto pr-1">
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Nama Lengkap</label>
                        <input type="text" wire:model="name" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                        @error('name') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Email</label>
                        <input type="email" wire:model="email" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                        @error('email') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">No. HP</label>
                        <input type="text" wire:model="phone" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Role Akses</label>
                        <select wire:model="role" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm bg-white focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                            <option value="pelanggan">Pembeli</option>
                            <option value="owner">Penjual</option>
                            <option value="admin">Admin</option>
                        </select>
                    </div>
                    <div class="space-y-1.5">
                        <label class="block text-xs font-bold text-slate-500 tracking-wide uppercase">Password</label>
                        <input type="password" wire:model="password" class="w-full rounded-xl border border-slate-200 px-4 py-3 text-sm focus:outline-none focus:ring-4 focus:ring-rose-500/10 focus:border-rose-400 transition-all duration-200">
                        @error('password') <p class="text-xs text-rose-500 font-bold mt-1">{{ $message }}</p> @enderror
                    </div>
                    <div class="bg-rose-50/50 border border-rose-100 rounded-xl p-3 text-[11px] text-rose-600 font-medium leading-relaxed">
                        Catatan: Toko untuk role Penjual baru tidak dibuat secara otomatis. Buat data tokonya melalui halaman Stores setelah akun berhasil terdaftar.
                    </div>
                </div>

                <div class="flex justify-end gap-3 pt-3 border-t border-slate-50">
                    <button wire:click="cancelForm" class="px-5 py-3 text-sm font-bold text-slate-500 hover:text-slate-700 bg-slate-50 hover:bg-slate-100 rounded-xl transition-all duration-200">
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
