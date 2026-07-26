import { AfterViewInit, ChangeDetectionStrategy, Component, EventEmitter, OnInit, Output, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import * as L from 'leaflet';

@Component({
  selector: 'app-facility-info-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './facility-info-form.component.html',
  styleUrl: './facility-info-form.component.css',
})
export class FacilityInfoFormComponent implements OnInit, AfterViewInit {
  @Output() next = new EventEmitter<any>();
  @Output() back = new EventEmitter<void>();

  form!: FormGroup;
  latitude = signal<number | null>(null);
  longitude = signal<number | null>(null);

  private map!: L.Map;
  private marker!: L.Marker;

  // Predefined business types
  businessTypes = [
    { value: 'llc', label: 'شركة ذات مسؤولية محدودة (LLC)' },
    { value: 'sole', label: 'مؤسسة فردية' },
    { value: 'joint', label: 'شركة مساهمة' },
    { value: 'partnership', label: 'شركة تضامن' },
  ];

  constructor(private fb: FormBuilder) {}

  ngOnInit(): void {
    this.form = this.fb.group({
      legalName: ['', [Validators.required, Validators.minLength(3)]],
      businessType: ['', Validators.required],
      registrationNumber: ['', [Validators.required, Validators.pattern(/^\d{10}$/)]],
      address: ['', Validators.required],
    });
  }

  ngAfterViewInit(): void {
    this.initMap();
  }

  private initMap(): void {
    // Cairo, Egypt coordinates
    const defaultLat = 30.0444;
    const defaultLng = 31.2357;

    this.latitude.set(defaultLat);
    this.longitude.set(defaultLng);

    // Initialize Leaflet Map
    this.map = L.map('map', {
      center: [defaultLat, defaultLng],
      zoom: 13,
      zoomControl: false,
    });

    L.control.zoom({ position: 'topright' }).addTo(this.map);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap contributors',
    }).addTo(this.map);

    // Custom CSS DivIcon for the map pin to avoid default asset packaging issues
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

    // Update coordinates on drag end
    this.marker.on('dragend', () => {
      const position = this.marker.getLatLng();
      this.latitude.set(position.lat);
      this.longitude.set(position.lng);
    });

    // Update marker and coordinates on map click
    this.map.on('click', (e: L.LeafletMouseEvent) => {
      this.marker.setLatLng(e.latlng);
      this.latitude.set(e.latlng.lat);
      this.longitude.set(e.latlng.lng);
    });
  }

  locateMe(): void {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const lat = position.coords.latitude;
          const lng = position.coords.longitude;
          
          this.latitude.set(lat);
          this.longitude.set(lng);
          
          this.map.setView([lat, lng], 15);
          this.marker.setLatLng([lat, lng]);
        },
        (error) => {
          console.warn('Geolocation error or permission denied:', error);
          alert('تعذر تحديد موقعك تلقائياً. يرجى تفعيل إذن تحديد الموقع أو تحديد موقعك يدوياً على الخريطة.');
        }
      );
    } else {
      alert('ميزة تحديد الموقع الجغرافي غير مدعومة في متصفحك.');
    }
  }

  onSubmit(): void {
    if (this.form.valid) {
      const formData = {
        ...this.form.value,
        coordinates: {
          lat: this.latitude(),
          lng: this.longitude(),
        },
      };
      this.next.emit(formData);
    } else {
      // Mark all controls as touched to trigger validation messages
      Object.keys(this.form.controls).forEach(key => {
        const control = this.form.get(key);
        control?.markAsTouched();
      });
    }
  }

  onBack(): void {
    this.back.emit();
  }
}
