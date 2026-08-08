import { Injectable } from '@angular/core';
import * as L from 'leaflet';

@Injectable({
  providedIn: 'root'
})
export class LeafletMapService {
  createMap(
    elementId: string, 
    center: L.LatLngExpression, 
    zoom: number = 13,
    onMarkerDragEnd?: (lat: number, lng: number) => void
  ): { map: L.Map; marker: L.Marker } {
    const map = L.map(elementId, {
      center,
      zoom,
      zoomControl: true,
      scrollWheelZoom: false
    });

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    const customPinIcon = L.divIcon({
      className: 'custom-div-icon',
      html: `<div class="marker-pin"></div><div class="marker-dot"></div>`,
      iconSize: [30, 42],
      iconAnchor: [15, 42]
    });

    const marker = L.marker(center, {
      icon: customPinIcon,
      draggable: true
    }).addTo(map);

    if (onMarkerDragEnd) {
      marker.on('dragend', (event: L.LeafletEvent) => {
        const position = event.target.getLatLng();
        onMarkerDragEnd(position.lat, position.lng);
      });
    }

    return { map, marker };
  }

  updateMarkerPosition(map: L.Map, marker: L.Marker, lat: number, lng: number): void {
    const newLatLng = new L.LatLng(lat, lng);
    marker.setLatLng(newLatLng);
    map.panTo(newLatLng);
  }

  getCurrentLocation(): Promise<{ lat: number; lng: number }> {
    return new Promise((resolve, reject) => {
      if (!navigator.geolocation) {
        reject(new Error('Geolocation is not supported by this browser.'));
        return;
      }
      navigator.geolocation.getCurrentPosition(
        (position) => {
          resolve({
            lat: position.coords.latitude,
            lng: position.coords.longitude
          });
        },
        (error) => reject(error),
        { enableHighAccuracy: true, timeout: 10000 }
      );
    });
  }
}
