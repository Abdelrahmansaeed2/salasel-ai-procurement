import { AfterViewInit, ChangeDetectionStrategy, Component, EventEmitter, OnInit, Output, signal, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import * as L from 'leaflet';
import { StepHeaderComponent } from '../shared/step-header/step-header.component';
import { FormActionsComponent } from '../shared/form-actions/form-actions.component';
import { LeafletMapService } from '../../services/leaflet-map.service';

@Component({
  selector: 'app-warehouse-info-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, StepHeaderComponent, FormActionsComponent],
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
  hasCargoDocks = signal<boolean>(true);
  selectedAddress = signal<string>('جدة، المملكة العربية السعودية');

  private map!: L.Map;
  private marker!: L.Marker;

  constructor(
    private fb: FormBuilder,
    private mapService: LeafletMapService
  ) {}

  ngOnInit(): void {
    this.form = this.fb.group({
      warehouseName: ['', [Validators.required, Validators.minLength(3)]],
      capacity: ['', [Validators.required, Validators.min(1)]],
      searchQuery: ['']
    });
  }

  ngAfterViewInit(): void {
    const defaultLat = 21.5433;
    const defaultLng = 39.1728;

    this.latitude.set(defaultLat);
    this.longitude.set(defaultLng);

    const result = this.mapService.createMap('warehouse-map', [defaultLat, defaultLng], 12, (lat, lng) => {
      this.updateLocation(lat, lng);
    });

    this.map = result.map;
    this.marker = result.marker;

    this.map.on('click', (e: L.LeafletMouseEvent) => {
      this.mapService.updateMarkerPosition(this.map, this.marker, e.latlng.lat, e.latlng.lng);
      this.updateLocation(e.latlng.lat, e.latlng.lng);
    });
  }

  ngOnDestroy(): void {
    if (this.map) {
      this.map.remove();
    }
  }

  toggleCargoDocks(available: boolean): void {
    this.hasCargoDocks.set(available);
  }

  onSearch(): void {
    const query = this.form.get('searchQuery')?.value;
    if (!query) return;

    this.selectedAddress.set(query);
    const offsetLat = (Math.random() - 0.5) * 0.05;
    const offsetLng = (Math.random() - 0.5) * 0.05;
    const newLat = 21.5433 + offsetLat;
    const newLng = 39.1728 + offsetLng;

    this.mapService.updateMarkerPosition(this.map, this.marker, newLat, newLng);
    this.latitude.set(newLat);
    this.longitude.set(newLng);
  }

  locateMe(): void {
    this.mapService.getCurrentLocation()
      .then(({ lat, lng }) => {
        this.mapService.updateMarkerPosition(this.map, this.marker, lat, lng);
        this.updateLocation(lat, lng);
        this.selectedAddress.set('موقعي الحالي');
      })
      .catch(() => {
        alert('تعذر تحديد موقعك الحالي. يرجى التحديد يدويًا على الخريطة.');
      });
  }

  onSubmit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.next.emit({
      ...this.form.value,
      hasCargoDocks: this.hasCargoDocks(),
      latitude: this.latitude(),
      longitude: this.longitude(),
      address: this.selectedAddress()
    });
  }

  onBackClick(): void {
    this.back.emit();
  }

  private updateLocation(lat: number, lng: number): void {
    this.latitude.set(lat);
    this.longitude.set(lng);
    this.selectedAddress.set(`إحداثيات: ${lat.toFixed(4)}, ${lng.toFixed(4)}`);
  }
}
