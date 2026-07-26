import { AfterViewInit, ChangeDetectionStrategy, Component, EventEmitter, OnInit, Output, signal, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import * as L from 'leaflet';

@Component({
  selector: 'app-warehouse-info-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './warehouse-info-form.component.html',
  styleUrl: './warehouse-info-form.component.css',
})
export class WarehouseInfoFormComponent implements OnInit, AfterViewInit, OnDestroy {
  @Output() next = new EventEmitter<any>();
  @Output() back = new EventEmitter<void>();

  form!: FormGroup;
  latitude = signal<number | null>(null);
  longitude = signal<number | null>(null);
  hasCargoDocks = signal<boolean>(true); // Defaults to 'Available' (متاح)
  selectedAddress = signal<string>('جدة، المملكة العربية السعودية');

  private map!: L.Map;
  private marker!: L.Marker;

  constructor(private fb: FormBuilder) {}

  ngOnInit(): void {
    this.form = this.fb.group({
      warehouseName: ['', [Validators.required, Validators.minLength(3)]],
      capacity: ['', [Validators.required, Validators.min(1)]],
      searchQuery: ['']
    });
  }

  ngAfterViewInit(): void {
    this.initMap();
  }

  ngOnDestroy(): void {
    if (this.map) {
      this.map.remove();
    }
  }

  private initMap(): void {
    // Jeddah, Saudi Arabia default coordinates
    const defaultLat = 21.5433;
    const defaultLng = 39.1728;

    this.latitude.set(defaultLat);
    this.longitude.set(defaultLng);

    // Initialize Leaflet Map with unique element ID to avoid conflicts
    this.map = L.map('warehouse-map', {
      center: [defaultLat, defaultLng],
      zoom: 12,
      zoomControl: false,
    });

    L.control.zoom({ position: 'topright' }).addTo(this.map);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors',
    }).addTo(this.map);

    // Custom CSS DivIcon for the map pin (reusing Step 1 styles)
    const customIcon = L.divIcon({
      className: 'custom-div-icon',
      html: `<div class="marker-pin"></div><i class="marker-dot"></i>`,
      iconSize: [30, 42],
      iconAnchor: [15, 42],
    });

    // Create marker
    this.marker = L.marker([defaultLat, defaultLng], {
      draggable: true,
      icon: customIcon,
    }).addTo(this.map);

    // Update coordinates and address representation on drag end
    this.marker.on('dragend', () => {
      const position = this.marker.getLatLng();
      this.updateLocation(position.lat, position.lng);
    });

    // Update marker on map click
    this.map.on('click', (e: L.LeafletMouseEvent) => {
      this.marker.setLatLng(e.latlng);
      this.updateLocation(e.latlng.lat, e.latlng.lng);
    });
  }

  toggleCargoDocks(available: boolean): void {
    this.hasCargoDocks.set(available);
  }

  onSearch(): void {
    const query = this.form.get('searchQuery')?.value;
    if (!query) return;

    // Simulated address geocoding for demonstration
    this.selectedAddress.set(query);
    
    // Pan to a random offset around Jeddah to simulate search update
    const offsetLat = (Math.random() - 0.5) * 0.05;
    const offsetLng = (Math.random() - 0.5) * 0.05;
    const newLat = 21.5433 + offsetLat;
    const newLng = 39.1728 + offsetLng;

    this.map.setView([newLat, newLng], 13);
    this.marker.setLatLng([newLat, newLng]);
    this.latitude.set(newLat);
    this.longitude.set(newLng);
  }

  locateMe(): void {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const lat = position.coords.latitude;
          const lng = position.coords.longitude;
          
          this.map.setView([lat, lng], 15);
          this.marker.setLatLng([lat, lng]);
          this.updateLocation(lat, lng);
          this.selectedAddress.set('موقعي الحالي');
        },
        (error) => {
          console.warn('Geolocation error:', error);
          alert('تعذر تحديد موقعك الحالي. يرجى التحديد يدويًا على الخريطة.');
        }
      );
    }
  }

  onSubmit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const formData = {
      ...this.form.value,
      hasCargoDocks: this.hasCargoDocks(),
      latitude: this.latitude(),
      longitude: this.longitude(),
      address: this.selectedAddress()
    };

    this.next.emit(formData);
  }

  onBackClick(): void {
    this.back.emit();
  }

  private updateLocation(lat: number, lng: number): void {
    this.latitude.set(lat);
    this.longitude.set(lng);
    
    // Simple mock reverse-geocoding coordinates representation
    const formattedCoords = `المنطقة الصناعية (إحداثيات: ${lat.toFixed(4)}، ${lng.toFixed(4)})`;
    this.selectedAddress.set(formattedCoords);
  }
}
